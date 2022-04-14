module "cognito-user-pool" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "0.15.2"
  # insert the 27 required variables here
  user_pool_name             = "poc-antivirus-pool"
  alias_attributes           = ["email", "phone_number"]
  auto_verified_attributes   = ["email"]
  sms_authentication_message = "Your username is {username} and temporary password is {####}."
  sms_verification_message   = "This is the verification message {####}."

  password_policy_require_lowercase                  = false
  password_policy_minimum_length                     = 11
  user_pool_add_ons_advanced_security_mode           = "OFF"
  verification_message_template_default_email_option = "CONFIRM_WITH_CODE"

  # schemas
  schemas = [
    {
      attribute_data_type      = "Boolean"
      developer_only_attribute = false
      mutable                  = true
      name                     = "available"
      required                 = false
    },
  ]

  string_schemas = [
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      name                     = "email"
      required                 = true

      string_attribute_constraints = {
        min_length = 10
        max_length = 100
      }
    },
  ]

  # user_pool_domain
  domain = "poc-antivirus"

  # client
  client_name                                 = "poc-antivirus-client"
  client_allowed_oauth_flows_user_pool_client = true
  client_supported_identity_providers         = ["COGNITO"]
  # identity_providers         = [ "Cognito User Pool" ]
  client_allowed_oauth_flows    = ["implicit"]
  client_allowed_oauth_scopes   = ["openid"]
  client_explicit_auth_flows    = ["USER_PASSWORD_AUTH"]
  client_callback_urls          = ["https://mydomain.com/callback"]
  client_default_redirect_uri   = "https://mydomain.com/callback"
  client_read_attributes        = ["email"]
  client_refresh_token_validity = 30
  client_generate_secret = false

  # user_group
  user_group_name        = "group1"
  user_group_description = "group 1"

  # ressource server
  #resource_server_identifier        = "https://mydomain.com"
  #resource_server_name              = "mydomain"
  resource_server_scope_name        = "scope"
  resource_server_scope_description = "a Sample Scope Description for mydomain"
}
