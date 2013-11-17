(load "RadForce")

(set USERNAME "")
(set PASSWORD "")
(set SECURITYTOKEN "")
(set CONSUMERKEY "")
(set CONSUMERSECRET "")

((SFConnection sharedInstance) setConsumerKey:CONSUMERKEY secret:CONSUMERSECRET)

(function display-result (result)
          (puts (result statusCode))
          (if (!= (result statusCode) 204)
              (puts ((result object) description))))

;; log in
(set result
     (RadHTTPClient connectSynchronouslyWithRequest:
                    ((SFConnection sharedInstance)
                     authenticateWithUsername:USERNAME
                     password:PASSWORD
                     securityToken:SECURITYTOKEN)))

((SFConnection sharedInstance) finishAuthenticatingWithResult:result)
(puts ((result object) description))

;; get survey results
(set result
     (RadHTTPClient connectSynchronouslyWithRequest:
                    ((SFConnection sharedInstance) queryRequestWithArguments:
                     (dict q:"SELECT Name, Id, Department, Email, Title FROM Contact ORDER BY CreatedDate DESC limit 100"))))

(display-result result)

