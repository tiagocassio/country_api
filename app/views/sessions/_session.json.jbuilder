json.extract! session.user, :id, :email
json.access_token session.signed_id
