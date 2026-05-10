platform :ios, '15.0'
use_frameworks!

target 'FinanceApp' do
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'FirebaseFirestoreSwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end

    next unless target.name == 'BoringSSL-GRPC'

    target.source_build_phase.files.each do |file|
      flags = file.settings && file.settings['COMPILER_FLAGS']
      next unless flags

      file.settings['COMPILER_FLAGS'] = flags.gsub('-GCC_WARN_INHIBIT_ALL_WARNINGS', '')
    end
  end

  [
    'gRPC-Core/src/core/lib/promise/detail/basic_seq.h',
    'gRPC-C++/src/core/lib/promise/detail/basic_seq.h'
  ].each do |relative_header_path|
    basic_seq_header = File.join(installer.sandbox.root, relative_header_path)

    next unless File.exist?(basic_seq_header)

    content = File.read(basic_seq_header)
    patched = content.gsub('Traits::template CallSeqFactory', 'Traits::CallSeqFactory')
    next if patched == content

    File.chmod(0644, basic_seq_header)
    File.write(basic_seq_header, patched)
  end
end
