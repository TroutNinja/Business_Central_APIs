# app_name: BC_Sandbox_Data_API
# description: Function that creates DataFrame by connecting to Web Services API in Business Central 220725 Sandbox Environment

BC_Sandbox_Data_API <- function (odata4_url) {
  
    # Load Packages
    pacman::p_load(httr2, jsonlite, dplyr, glue)
    
    # Load credentials
    tenant_id <- Sys.getenv("tenant_id")
    client_id <- Sys.getenv("client_id")
    client_secret <- Sys.getenv("client_secret")
    
    # Assign web services OData 4 URLs to table name variables
    od4_url <- odata4_url
    
    # Create Oauth login url
    microsoft_oauth_login_url <- paste(c("https://login.microsoftonline.com/", tenant_id, "/oauth2/v2.0/token"), collapse = "")
    
    # Create client and get token
    client <- httr2::oauth_client(id = client_id,
                                  token_url = microsoft_oauth_login_url,
                                  secret = client_secret,
                                  key = NULL,
                                  auth = c("body", "header", "jwt_sig"),
                                  auth_params = list(),
                                  name = NULL)
    
    cred <- oauth_flow_client_credentials(client, scope = "https://api.businesscentral.dynamics.com/.default", token_params = list())
    
    # Define HTTP request object
    req <- request(od4_url) %>% req_auth_bearer_token(cred$access_token)
    
    # Fetch request
    perform <- req_perform(req)
    
    # Create DataFrame
    df <- resp_body_json(perform, check_type = TRUE, simplifyVector = TRUE)$value
    
    return (df)

}


