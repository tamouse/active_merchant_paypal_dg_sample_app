require 'sinatra/base'
require 'active_merchant'
require 'yaml'

$SandboxFlag = true

class ActiveMerchantPaypalApp < Sinatra::Base

  enable :logging

  CONFIG = YAML.load(File.read(
      File.expand_path("_paypal_business_api_credentials.yml")
      ))

  if $SandboxFlag == true
    API_ENDPOINT = "https://api-3t.sandbox.paypal.com/nvp"
    PAYPAL_URL = "https://www.sandbox.paypal.com/webscr?cmd=_express-checkout&token="
    PAYPAL_DG_URL = "https://www.sandbox.paypal.com/incontext?token="
  else
    API_ENDPOINT = "https://api-3t.paypal.com/nvp"
    PAYPAL_URL = "https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token="
    PAYPAL_DG_URL = "https://www.paypal.com/incontext?token="
  end
  
  ActiveMerchant::Billing::Base.mode = :test
  GATEWAY = ActiveMerchant::Billing::PaypalDigitalGoodsGateway.new(
    :login => CONFIG['username'],
    :password => CONFIG['password'],
    :signature => CONFIG['signature']
    )

  get '/' do
    logger.info "GET /"
    haml :index, :format => :html5, :layout => :default
  end

  post '/subscribe' do
    logger.info "POST /subscribe #{params.inspect}"

    #return_url = "http://active_merchant_sample_app.192.168.1.72.xip.io/confirm"
    return_url ="http://active_merchant_sample_app.10.105.5.193.xip.io/confirm"
    cancel_url = return_url

    items = [{
        :name => 'Subscription',
        :number => "1",
        :quantity => "1",
        :amount => 249,
        :description => "Monthly Brewtoad Subscription",
        :category => "Digital"
      }]

    options = {
      :ip => "127.0.0.1",
      :description => "Paypal Test Transaction",
      :return_url => return_url,
      :cancel_return_url => cancel_url,
      :items => items
    }

    logger.info "Options: #{options.inspect}"

    result = GATEWAY.setup_purchase(249, options)
    
    logger.info "Result: #{result.inspect}"

    if result['ACK'].downcase.include? "success"
      token = result['token']
      redirect to("#{PAYPAL_DG_URL}#{token}")
    else
      "<h1>ERROR!</h1><p>#{result.inspect}</p>"
    end

  end

  get '/confirm' do
    params.inspect
  end
  
  post '/confirm' do
    params.inspect
  end
  
end
