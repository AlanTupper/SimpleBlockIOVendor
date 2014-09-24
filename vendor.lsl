string item;
key rq;
integer price;
key buyer;


default
{
    on_rez(integer n){llResetScript();}
    
    state_entry()
    {
        llSetText("",ZERO_VECTOR,0.0);
        if(item != ""){ state ready; }    
    }
    
    touch_start(integer n){ if(llDetectedKey(0) == llGetOwner()) { state init;} }  
    
}

state ready
{
    state_entry()
    {
        string buy_msg = "Buy for " + (string)price + "Ð";
        llSetText(buy_msg,<1.0,1.0,1.0>,1.0);
        buyer = NULL_KEY;
    }
      
    touch_start(integer n)
    {
        buyer = llDetectedKey(0);
        state checking_out;    
    } 
}

state init
{
    state_entry()
    {
        rq = llGetNotecardLine("Vendor_Config",0);
    }
    
    dataserver(key q, string data)
    {
        list params;
        if(q == rq && data != EOF)
        {
            params = llParseString2List(data,[",",":"],[]);
            integer i;
            string val_key;
            
            integer len = llGetListLength(params);
            if(len%2 != 0){state init_error;} //if it's not an even set of key/values, error out.
            
            for (; i < len; i= i+2)
            {
                val_key = llList2String(params,i);
                if(val_key == "item"){item = llList2String(params,i+1);} 
                else if(val_key == "price"){price = llList2Integer(params,i+1);}
            }
            
            if(item == ""){ state init_error;}
            
            state default;
        }
        else
        { state init_error; }    
    }    
}

state checking_out
{
    state_entry()
    {
        llMessageLinked(LINK_SET,price,"CHECKOUT",buyer);      
    }
    
    link_message(integer origin, integer status, string msg, key id)
    {
        if (msg == "COMPLETE")
        {
            if (status == TRUE)
            {
                llSay(0,"Vending Item, please wait!");
                llGiveInventory(buyer,item);
                state default;
            }
            else { state default; }    
        }
    }        
}

state init_error
{
    state_entry()
    {
        llOwnerSay("Error occurred setting up vendor.");    
    }
    
    touch_start(integer n)
    {
        if(llDetectedKey(0) == llGetOwner()){llResetScript();}    
    }    
}
