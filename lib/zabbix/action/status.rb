require "zabbix/action/status/version"
require 'net/https'
require 'json'

class Zabbix
  class Action
    class Status
      def initialize(zabbix_api_url, zabbix_action_ids)
        @api_uri = URI.parse(zabbix_api_url)
        @action_ids = zabbix_action_ids
      end

      # zabbixの通知をoffにする
      def disable
        auth_key = send_auth_request()
        action_status_hash = get_target_actions_status(auth_key, @action_ids)
        # ステータスを変える
        @action_ids.each do |id|
          result = update_zabbix_action_disable_status(auth_key, id) if action_status_hash[id] == "0"
          check_error_json_response(result)
        end

        # 最終チェック
        result_status = get_target_actions_status(auth_key, @action_ids)
        @action_ids.each do |id|
          raise 'ERROR:zabbix status error'+result_status.to_s if result_status[id] == "0"
        end
      end

      # zabbixの通知をonにする
      def enable
        auth_key = send_auth_request()
        action_status_hash = get_target_actions_status(auth_key, @action_ids)
        # ステータスを変える
        @action_ids.each do |id|
          result = update_zabbix_action_enable_status(auth_key, id) if action_status_hash[id] == "1"
          check_error_json_response(result)
        end

        # 最終チェック
        result_status = get_target_actions_status(auth_key, @action_ids)
        @action_ids.each do |id|
          raise 'ERROR:zabbix status error' + result_status.to_s if result_status[id] == "1"
        end
      end

      private

      # 認証キーを取得する
      def send_auth_request
        authenticate_request = create_post_request(get_zabbix_authenticate_request_json)
        authenticate_response = send_reqest(authenticate_request)
        authenticatedhash = parse_response_hash(authenticate_response)
        authenticatedhash['result']
      end

      # 対象actionIdのステータスをhashで取得する
      def get_target_actions_status(auth_key, target_action_ids)
        request_body = get_zabbix_status_check_request_json(auth_key, target_action_ids)
        check_status_request = create_post_request(request_body)
        check_status_response = send_reqest(check_status_request)
        status_hash = parse_response_hash(check_status_response)

        result_action_status_hash = Hash.new
        status_hash['result'].each do |json|
          result_action_status_hash.store(json['actionid'],json['status'] )
        end
        result_action_status_hash
      end

      # zabbixに対してauth認証用をリクエストするjsonを取得する
      def get_zabbix_authenticate_request_json
        {
          jsonrpc: '2.0',
          method: 'user.login',
          params: {
            user: 'admin',
            password: 'passzabbixpass'
          },
          id: 1
        }.to_json
      end

      # zabbixに対して対象のactionIdのステータスを取得するjsonを取得する
      def get_zabbix_status_check_request_json(auth_str, target_action_ids)
        {
          auth: auth_str,
          jsonrpc:"2.0",
          method:"action.get",
          params:{
            output: "extend",
            filter: {
              actionid:target_action_ids
            }
          },
          id: 1
        }.to_json
      end

      # postリクエストを作成します
      def create_post_request(body_desc)
        request = Net::HTTP::Post.new(@api_uri.request_uri, initheader = {'Content-Type' =>'application/json'})
        request.body = body_desc
        request
      end

      # requestを元にリクエストしてresponse を受け取る
      def send_reqest(request)
        response = nil
        http = create_http_connection
        http.start do |h|
          response = h.request(request)
        end

        case response
        when Net::HTTPSuccess
          response
        else
          raise [uri.to_s, response.value].join(' : ').to_s
        end
      end

      # httpのコネクションを作成する
      def create_http_connection
        http = Net::HTTP.new(@api_uri.host, @api_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        # debug 用
        # http.set_debug_output $stderr
        http
      end

      # response をパースして hashオブジェクトに変換
      def parse_response_hash(response)
        responseParsedJson = JSON.parser.new(response.body)
        responseParsedJson.parse
      end

      # 返ってきたレスポンスのJSONの中身がエラーかどうか
      def check_error_json_response(response)
        if response
          status_hash = parse_response_hash(response)
          if status_hash['error']
            raise status_hash['error'].to_s
          end
        end
      end

      # 対象のacitonIdの通知ステータスをOFFにする
      def update_zabbix_action_disable_status(auth_key, target_action_id)
        request_body = get_zabbix_action_status_disable_json(auth_key, target_action_id)
        authenticate_request = create_post_request(request_body)
        send_reqest(authenticate_request)
      end

      # 対象のacitonIdの通知ステータスをONにする
      def update_zabbix_action_enable_status(auth_key, target_action_id)
        request_body = get_zabbix_action_status_enable_json(auth_key, target_action_id)
        authenticate_request = create_post_request(request_body)
        send_reqest(authenticate_request)
      end

      # zabbixに対して通知をOFFにするJsonを取得する
      def get_zabbix_action_status_disable_json(auth_key, target_action_id)
        {
          auth: auth_key,
          jsonrpc:"2.0",
          method:"action.update",
          params:{
            actionid:target_action_id,
            status:1
          },
          id: 1
        }.to_json
      end

      # zabbixに対して通知をONにするJsonを取得する
      def get_zabbix_action_status_enable_json(auth_key, target_action_id)
        {
          auth: auth_key,
          jsonrpc:"2.0",
          method:"action.update",
          params:{
            actionid:target_action_id,
            status:0
          },
          id: 1
        }.to_json
      end
    end
  end
end
