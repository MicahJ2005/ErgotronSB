global with sharing class CC_ERG_ValidateUser_ext {
  public CC_ERG_ValidateUser_ext(CC_ERG_Header_PLOT stdController) {
  }

  @RemoteAction
  global static CC_ERG_ValidateUser_ext.Response checkUserAlreadyExist(
    String username
  ) {
    Response objResponse = new Response();
    objResponse.isError = true;  
    try {
      if ([SELECT id FROM User WHERE username = :username]?.size() < 1) {
        objResponse.isError = false;
      } else {
        objResponse.errorMessage = 'User already exists. Please login instead.';
      }
      return objResponse;
    } catch (Exception ex) {
      objResponse.errorMessage = 'Problem with registrastion. Please contact us.';
      return objResponse;
    }
  }

  @JsonAccess(serializable='always' deserializable='always')
  global class Response {
    Boolean isError { get; set; }
    String errorMessage { get; set; }
  }
}