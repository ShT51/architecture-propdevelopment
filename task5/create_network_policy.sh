# функция по созданию новых "сервисов"
create_app() {
  local app_name=$1
  
  kubectl run ${app_name}-app --image=nginx --labels role=${app_name} --expose --port 80 -n task7-ns

}

echo "Создаем новый неймспейс"
kubectl create namespace task7-ns

echo
echo "Создаем новые сервисы"
create_app "front-end"
create_app "back-end-api"
create_app "admin-front-end"
create_app "admin-back-end-api"

echo
echo "Применяем сетевые политики"
kubectl apply -f non-admin-api-allow.yaml