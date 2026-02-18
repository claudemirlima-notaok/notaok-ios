#!/bin/bash
# Remove o post_install duplicado que acabamos de adicionar
head -n -7 Podfile > Podfile.tmp

# Adiciona o post_install correto (substitui o antigo)
cat >> Podfile.tmp << 'PODFILE_END'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
PODFILE_END

mv Podfile.tmp Podfile
