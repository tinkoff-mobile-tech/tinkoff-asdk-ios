# Быстрый старт
start:
	make gen
	make open_workspace

open_workspace:
	open ASDKSample/ASDKSample.xcworkspace;

gen:
# Устанавливаем зависимости для семпла
	cd 'ASDKSample'; bundle exec pod install || bundle exec pod install --repo-update

clean_podlock:
	git checkout -- ASDKSample/Podfile.lock

snapshot_testing:
# Добавляем тест под для снепшот тестирования 
	cd 'ASDKSample'; swift '.hidden/podfile_remove_comments.swift'
# Копируем оригинал вспомогательной подспеки для снепшот тестов
	cp 'ASDKSample/.hidden/TestsSharedInfrastructure' 'TestsSharedInfrastructure.podspec'
	make gen
# Комментируем тест под для снепшот тестирования
	cd 'ASDKSample'; swift '.hidden/podfile_add_comments.swift'
# Удаляем вспомогательную подспеку чтобы не попала в релиз publish action
	rm -rf 'TestsSharedInfrastructure.podspec'
#	make clean_podlock
	make open_workspace