({
	helperMethod : function() {
		
	},
    getQueryVariable : function(variable) {
       debugger;
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       var myValue = '';
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){ 
                   debugger;
                   //return pair[1]; 
                   myValue = pair[1];
                   i = vars.length;
               }
       }
       debugger;
       return myValue;
       //return(false);
	}
})