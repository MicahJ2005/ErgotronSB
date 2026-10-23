/**
* An apex page controller that exposes the change password functionality
*/
public without sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String userName {get; set;}
    public DateTime lastPasswordChangeDate {get; set;} 
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    public String LastLoginDate {get;set;}
    
    

    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
    
    
    public ChangePasswordController() {
        User u = [select id, contactId, LastLoginDate, userName, lastpasswordchangeDate from User where id = :UserInfo.getUserId()];
        LastLoginDate = string.ValueOf(u.LastLoginDate);
        userName = u.userName;
        lastPasswordChangeDate = u.lastpasswordchangeDate;
    }
}