start:
# Копируем оригинал вспомогательной подспеки для снепшот тестов
	cp 'ASDKSample/TestsSharedInfrastructure' 'TestsSharedInfrastructure.podspec'
# Устанавливаем зависимости для семпла
	cd 'ASDKSample'; bundle exec pod install || bundle exec pod install --repo-update
# Удаляем вспомогательную подспеку чтобы не попала в релиз publish action
	rm -rf 'TestsSharedInfrastructure.podspec'
# Открываем проект
	open ASDKSample/ASDKSample.xcworkspace;