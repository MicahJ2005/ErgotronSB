trigger Price_Book on Pricebook2 (after insert) {
    if(BypassTriggers.bypass()){
        return;
    }
    for (Pricebook2 priceBook : Trigger.New){
        Flow.Interview flow = new Flow.Interview.Price_Book_to_CC_Price_List(new map<String,Object> {'recordId' => priceBook.Id});     
        flow.start();        
    }   
}