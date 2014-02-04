require 'sinatra'
require 'active_merchant'
require 'yaml'

CONFIG = YAML.load(File.read(
    File.expand_path("../paypal_api_signature.yml")
    ))

STDERR.puts CONFIG

ActiveMerchant::Billing::Base.mode = :test
GATEWAY = ActiveMerchant::Billing::PaypalDigitalGoodsGateway.new(
  :login => CONFIG['API_Username'],
  :password => CONFIG['API_Password'],
  :signature => CONFIG['Signature']
  )

get '/' do
  haml :index, :format => :html5, :layout => :default
end

post '/subscribe' do
  credit_card = ActiveMerchant::Billing::CreditCard.new(
    :first_name => params['first_name'],
    :last_name => params["last_name"],
    :number => params["number"],
    :month => params["exp_month"],
    :year => params["exp_year"],
    :verification_value => params["cvv"]
    )

  if credit_card.valid?
    amount = 200                # two dollah
    recurring_profile = GATEWAY.recurring(amount,
      credit_card,
      {
        :period => "Month",
        :frequency => 1,
        :start_date => Date.today,
        :description => "Monthly Brewtoad Subscription"
      }
      )
    if recurring_profile.success?
      message = "Successfully charged %.2f to the credit card %s" % [ (amount.to_f / 100.0), credit_card.display_number ]
    else
      message = "Charge failed: #{recurring_profile.message}"
    end
    
  end

  haml( :subscribe_complete,
        :format => :html5,
        :layout => :default,
        :locals => {
          :message => message,
          :parameters => params.inspect,
          :credit_card => credit_card.inspect,
          :recurring_profile => recurring_profile.inspect}
        )
end
