require 'sinatra/base'
require 'active_merchant'
require 'yaml'

class ActiveMerchantPaypalApp < Sinatra::Base

  enable :logging

  CONFIG = YAML.load(File.read(
      File.expand_path("_paypal_business_api_credentials.yml")
      ))

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

    result.inspect
  end

  get '/confirm' do
    params.inspect
  end
  
  post '/confirm' do
    params.inspect
  end
  
end
