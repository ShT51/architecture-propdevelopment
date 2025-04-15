#!/bin/bash

mkdir -p certificates

# функция по созданию пользователей с группами и их сертификатов
create_user_cert() {
  local username=$1
  local group=$2

  openssl genrsa -out certificates/${username}.key 2048
  openssl req -new -key certificates/${username}.key -out certificates/${username}.csr -subj "/CN=${username}/O=${group}"
  openssl x509 -req -in certificates/${username}.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out certificates/${username}.crt -days 365
}

# функция по добавлению пользователей в кластер
add_user() {
  local username=$1
  kubectl config set-credentials ${username} --client-certificate=certificates/${username}.crt --client-key=certificates/${username}.key
}

# функция по проверки доступов
check_user_access() {
  local username=$1
  echo "Can I as '${username}' GET deployments --> '$(kubectl --user=${username} auth can-i get deployments)'" 
  echo "Can I as '${username}' DELETE deployments --> '$(kubectl --user=${username} auth can-i delete deployments)'" 
  echo "Can I as '${username}' GET secrets --> '$(kubectl --user=${username} auth can-i get secrets)'" 
}


echo
echo "создание сертификатов для пользователей..."
create_user_cert "security-specialist" "security-specialists-group"
create_user_cert "support-engineer" "support-engineers-group"
create_user_cert "devops-engineer" "devops-engineers-group"

echo
echo "добавление пользователей в кластер..."
add_user "security-specialist"
add_user "support-engineer"
add_user "devops-engineer"
echo
kubectl config get-users

echo
echo "Создаем роли и свзязываем их с группами пользователей..."
kubectl apply -f ./roles.yaml
kubectl apply -f ./roles-binding.yaml

echo
echo "Проверка доступов для пользователей..."
check_user_access "security-specialist"
check_user_access "support-engineer"
check_user_access "devops-engineer"