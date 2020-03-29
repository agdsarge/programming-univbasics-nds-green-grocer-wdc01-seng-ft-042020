require 'pp'
my_cart = [{item: "AVOCADO", price: 3.00, clearance: true},
    {item: "AVOCADO", price: 3.00, clearance: true},
    {item: "AVOCADO", price: 3.00, clearance: true},
    {item: "AVOCADO", price: 3.00, clearance: true},
    {item: "AVOCADO", price: 3.00, clearance: true},
    {item: "KALE", price: 3.00, clearance: false},
    {item: "RADISH", price: 2.00, clearance: false},
    {item: "RADISH", price: 2.00, clearance: false},
    {item: "AVOCADO", price: 3.00, clearance: true},
    {item: "RADISH", price: 2.00, clearance: false},
    {item: "APPLE", price: 10.00, clearance: true},
    {item: "APPLE", price: 10.00, clearance: true},
    {item: "KIWI", price: 6.00, clearance: true}
]

my_coupons = [{:item => "AVOCADO", :num => 3, :cost => 5.00},
    {item: "KALE", num: 2, cost: 4.00},
    {item: "BAGELS", num: 12, cost: 13.00},
    {item: "APPLE", num: 2, cost: 1.00},
    {:item => "RADISH", :num => 9999, :cost => 5.00}
]

my_consolidated_cart = [
    {item: "APPLE", price: 10.00, clearance: true, count: 2},
    {item: "KIWI", price: 6.00, clearance: true, count: 1},
    {item: "AVOCADO", price: 3.00, clearance: true, count: 7},
    {item: "RADISH", price: 2.00, clearance: false, count: 3},
    {item: "KALE", price: 3.00, clearance: false, count: 2},
]

def find_item_by_name_in_collection(name, collection)

  cart_index = 0
  while cart_index < collection.length do
    if collection[cart_index][:item] == name
      return collection[cart_index]
    end
    cart_index += 1
  end
  return nil
end #returns hash with :item == name

def copy_cart(cart)
  temp_cart = []
  cart_index = 0
  while cart_index < cart.length do
    temp_cart << cart[cart_index]
    cart_index += 1
  end
  return temp_cart
end #copies a cart so you don't have to worry about mutating the input

def count_key(cart)
    cart_index = 0
    while cart_index < cart.length do
        cart[cart_index][:count] = 1
        cart_index += 1
    end
    return cart
end #adds a :count = 1 key to each item in the cart

def consolidate_cart(cart)
  solid_cart = []
  temp_cart = count_key(copy_cart(cart))
  temp_index = 0
  while temp_index < temp_cart.length do #now we loop through the temp_cart array. all elements are hashes.
      #if the item is not in solid cart, add it
      item = temp_cart[temp_index]
     if !find_item_by_name_in_collection(item[:item], solid_cart)
         solid_cart << temp_cart[temp_index]
     end
     temp_index += 1
    end

  solid_index = 0
  while solid_index < solid_cart.length do
      solid_cart[solid_index][:count] = temp_cart.count(solid_cart[solid_index])
      solid_index += 1
  end
  return solid_cart
end

def coupon_test(food, coupons) #food is consolidated hash
    if find_item_by_name_in_collection(food[:item], coupons)
        if find_item_by_name_in_collection(food[:item], coupons)[:num] <= food[:count]
            return true
        end
    end
return false
end #returns TRUE if the item is in the cart and the num > count

def coupon_num(food, coupons)
    return find_item_by_name_in_collection(food[:item], coupons)[:num]
end #returns the coupon :num value as an Integer

def coupon_price(coupon)
    adjusted_price = coupon[:cost] / coupon[:num]
    return adjusted_price.round(2)
end

def apply_coupons(cart, coupons)
    #both arguments are arrays. cart is consolidated.
    #do we want to loop through the cart or through the coupons?
    #since we want to mutate the cart, let's loop through the cart.
    cart_index = 0
    temp_coupons = copy_cart(coupons)
    while cart_index < cart.length do
        thing = cart[cart_index] #consolidated food hash under consideration

        if coupon_test(thing, temp_coupons)
            coupon_of_interest = find_item_by_name_in_collection(thing[:item], temp_coupons) #coupon hash
            adj_price = coupon_price(coupon_of_interest)
            coupon_number = coupon_num(thing, temp_coupons)
            cart << {item: "#{thing[:item]} W/COUPON", price: adj_price, clearance: thing[:clearance], count: coupon_number }
            temp_coupons.delete(coupon_of_interest)
            thing[:count] -= coupon_number
        end
        cart_index += 1
    end
    #new_index = 0
    #while new_index < cart.length do
    #    if cart[new_index][:count] == 0
    #        cart.delete(cart[new_index])
    #    end
    #    new_index += 1
    #end
    return cart
end

def apply_clearance(cart)
  # Consult README for inputs and outputs
  #
  # REMEMBER: This method **should** update cart
  cart_index = 0
  while cart_index < cart.length do
    if cart[cart_index][:clearance] == true
      cart[cart_index][:price] *= 0.8
      cart[cart_index][:price] = cart[cart_index][:price].round(2)
    end
    cart_index += 1
  end
  
  return cart
end

def checkout(cart, coupons)
  cc = consolidate_cart(cart)
  apply_coupons(cc, coupons)
  new_cart = apply_clearance(cc)
  
  cart_index = 0
  sub_total = 0
  while cart_index < new_cart.length do
    sub_total += new_cart[cart_index][:count] *  new_cart[cart_index][:price]   
  
    cart_index += 1
  end
  
  if sub_total > 100
    sub_total *= 0.90
  end
  return sub_total
end
