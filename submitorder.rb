require './oneflowclient'
require './models/order'
require './models/item'
require './models/component'
require './models/shipment'
require './models/carrier'
require './models/address'
require 'json'

#initialise the sdk
endpoint = "http://stage.oneflowcloud.com/api"
token = "1252524138534"
secret = "8cea092e6047af8670d1650dc29896eb1e5b2d1f7e57f44d"

#order settings
destination = "order-test"
orderId = "order-"+rand(1000000).to_s
itemId = orderId + "-1"
fetchUrl = "http://www.analysis.im/uploads/seminar/pdf-sample.pdf"
quantity = 1
skuCode = "test-sku"
componentCode = "text"
carrierCode = "royalmail"
carrierService = "firstclass"
name = "Nigel Watson"
address1 = "999 Letsbe Avenue"
town = "London"
postcode = "EC2N 0BJ"
isoCountry = "GB"

# No need to edit below here

#create the onelflow client
client = OneflowClient.new(endpoint, token, secret)

order = client.create_order(destination)
order.orderData.sourceOrderId = orderId
item = Item.new
item.sku = skuCode
item.quantity = quantity
item.sourceItemId = itemId

component = Component.new
component.code = componentCode
component.fetch = false
component.path = fetchUrl
item.components.push(component)
order.orderData.items.push(item)

shipment = Shipment.new
shipment.carrier = Carrier.new(carrierCode, carrierService)
address = Address.new
address.name = name
address.address1 = address1
address.town = town
address.isoCountry = isoCountry
address.postcode = postcode
shipment.shipTo = address
order.orderData.shipments.push(shipment)

response = client.submit_order
response_json = JSON.parse(response.body)

if (response_json["error"])
    puts "Error"
    puts "====="
    puts response_json["error"]["message"]
    if (response_json["error"]["code"])
        response_json["error"]["validations"].each {|val| puts val["path"] + " -> " + val["message"]}
    end
else
    saved_order = response_json["order"]

    puts "Success"
    puts "======="
    puts "Order ID        : " + saved_order["_id"]

#    for file in saved_order["files"]
#        puts "Uploading File  : " + file["_id"]
#        # res = client.upload_file(file, "files/" + file["path"])
#    end
end
