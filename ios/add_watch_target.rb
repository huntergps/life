#!/usr/bin/env ruby
# =============================================================================
# add_watch_target.rb
# Agrega/recrea el target watchOS "GalapagosWatch" al Runner.xcodeproj.
#
# Uso:
#   cd ios && ruby add_watch_target.rb
#
# Requiere: gem install xcodeproj  (xcodeproj 1.27.0)
#
# NOTAS TÉCNICAS:
#   - Usa product_type :application (com.apple.product-type.application)
#     con SDKROOT=watchos para watchOS 7+ standalone app (SwiftUI @main App)
#   - NO usa :watch2_app (com.apple.product-type.application.watchapp2) que
#     era para el modelo antiguo WatchKit App + Extension y causa errores de
#     "Multiple commands produce" en Xcode 14+
#   - ComplicationProvider.swift NO se incluye (requiere target WidgetKit aparte)
# =============================================================================

require 'xcodeproj'
require 'fileutils'

PROJECT_PATH    = File.join(__dir__, 'Runner.xcodeproj')
WATCH_DIR       = File.join(__dir__, 'GalapagosWatch')
BUNDLE_ID_BASE  = 'tech.galapagos.galapagosWildlife'
WATCH_BUNDLE_ID = "#{BUNDLE_ID_BASE}.watchkitapp"
TEAM_ID         = 'W8V3ANSPKT'
WATCH_OS_VER    = '10.0'
SWIFT_VERSION   = '5.0'

puts "\n🕐 Abriendo proyecto Xcode..."
project = Xcodeproj::Project.open(PROJECT_PATH)

# =============================================================================
# 0. Limpiar targets/grupos/fases existentes de GalapagosWatch
# =============================================================================
puts "🧹 Limpiando configuración anterior..."

# Eliminar target existente
existing_target = project.targets.find { |t| t.name == 'GalapagosWatch' }
if existing_target
  existing_target.remove_from_project
  puts "   ✅ Target GalapagosWatch eliminado"
end

# Eliminar grupo de archivos existente
existing_group = project.main_group.groups.find { |g| g.display_name == 'GalapagosWatch' }
if existing_group
  existing_group.remove_from_project
  puts "   ✅ Grupo GalapagosWatch eliminado"
end

# Eliminar fase "Embed Watch Content" del Runner si existe
runner_target = project.targets.find { |t| t.name == 'Runner' }
if runner_target
  # Eliminar CopyFiles AND Shell Script phases (pueden acumularse si el script corre varias veces)
  (runner_target.copy_files_build_phases + runner_target.shell_script_build_phases).select { |p|
    p.name == 'Embed Watch Content'
  }.each do |phase|
    phase.remove_from_project
    puts "   ✅ Fase 'Embed Watch Content' eliminada de Runner"
  end

  # Eliminar dependencias antiguas de GalapagosWatch
  runner_target.dependencies.select { |d|
    d.target_proxy&.remote_info == 'GalapagosWatch'
  }.each do |dep|
    dep.remove_from_project
    puts "   ✅ Dependencia GalapagosWatch eliminada de Runner"
  end
end

# Limpiar frameworks duplicados de GalapagosWatch
['HealthKit.framework', 'CoreLocation.framework'].each do |fw|
  project.frameworks_group.files.select { |f| f.path == fw }.each do |ref|
    ref.remove_from_project
  end
end

project.save
puts "   ✅ Proyecto limpiado\n\n"

# =============================================================================
# 1. Crear el target watchOS (modern standalone SwiftUI App)
# =============================================================================
puts "➕ Creando target GalapagosWatch (watchOS standalone app)..."

# :application = com.apple.product-type.application con SDK watchos
# Es el tipo correcto para apps SwiftUI modernas en watchOS 7+
watch_target = project.new_target(
  :application,
  'GalapagosWatch',
  :watchos,
  WATCH_OS_VER
)

# =============================================================================
# 2. Configurar build settings
# =============================================================================
puts "⚙️  Configurando build settings..."

watch_target.build_configurations.each do |config|
  s = config.build_settings

  # Identidad
  s['PRODUCT_NAME']                 = 'GalapagosWatch'
  s['PRODUCT_BUNDLE_IDENTIFIER']    = WATCH_BUNDLE_ID
  s['DEVELOPMENT_TEAM']             = TEAM_ID

  # Plataforma watchOS
  s['SDKROOT']                      = 'watchos'
  s['SUPPORTED_PLATFORMS']          = 'watchos watchsimulator'
  s['TARGETED_DEVICE_FAMILY']       = '4'
  s['WATCHOS_DEPLOYMENT_TARGET']    = WATCH_OS_VER
  s['ARCHS']                        = 'arm64 arm64_32'
  s['VALID_ARCHS']                  = 'arm64 arm64_32 arm64e'

  # Swift
  s['SWIFT_VERSION']                = SWIFT_VERSION
  s['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS']      = ['$(inherited)', '@executable_path/Frameworks']

  # Firma y recursos
  s['CODE_SIGN_STYLE']              = 'Automatic'
  s['CODE_SIGN_ENTITLEMENTS']       = 'GalapagosWatch/GalapagosWatch.entitlements'
  s['ENABLE_BITCODE']               = 'NO'
  s['INFOPLIST_FILE']               = 'GalapagosWatch/Info.plist'
  s['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'

  # Instalación
  s['SKIP_INSTALL']                 = 'NO'
  s['INSTALL_PATH']                 = '$(LOCAL_APPS_DIR)'

  case config.name
  when 'Release'
    s['SWIFT_OPTIMIZATION_LEVEL']            = '-Owholemodule'
    s['VALIDATE_PRODUCT']                    = 'YES'
    s['DEBUG_INFORMATION_FORMAT']            = 'dwarf-with-dsym'
  when 'Debug'
    s['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
    s['SWIFT_OPTIMIZATION_LEVEL']            = '-Onone'
    s['DEBUG_INFORMATION_FORMAT']            = 'dwarf'
  end
end

puts "   ✅ Build settings configurados"

# =============================================================================
# 3. Crear grupo de archivos en el proyecto
# =============================================================================
puts "📁 Creando grupos de archivos..."

watch_group         = project.main_group.new_group('GalapagosWatch', 'GalapagosWatch')
models_group        = watch_group.new_group('Models',        'Models')
views_group         = watch_group.new_group('Views',         'Views')
services_group      = watch_group.new_group('Services',      'Services')
complications_group = watch_group.new_group('Complications', 'Complications')

# =============================================================================
# 4. Agregar archivos Swift al target
#    NOTA: ComplicationProvider.swift NO se incluye en este target.
#          Las complicaciones requieren un target WidgetKit Extension separado.
# =============================================================================
puts "📄 Agregando archivos Swift al target..."

def add_source(group, target, full_path)
  raise "Archivo no encontrado: #{full_path}" unless File.exist?(full_path)
  ref = group.new_file(full_path)
  ref.set_explicit_file_type('sourcecode.swift')
  target.add_file_references([ref])
  puts "   ✅ #{File.basename(full_path)}"
  ref
end

# Archivos raíz del Watch app
['GalapagosWatchApp.swift', 'ContentView.swift'].each do |f|
  add_source(watch_group, watch_target, File.join(WATCH_DIR, f))
end

# Modelos
['WatchSighting.swift', 'WatchSpecies.swift'].each do |f|
  add_source(models_group, watch_target, File.join(WATCH_DIR, 'Models', f))
end

# Vistas
['SightingLoggerView.swift', 'TrailRecordingView.swift', 'SpeciesListView.swift'].each do |f|
  add_source(views_group, watch_target, File.join(WATCH_DIR, 'Views', f))
end

# Servicios
['WatchConnectivityService.swift', 'LocationService.swift', 'LocalStorageService.swift'].each do |f|
  add_source(services_group, watch_target, File.join(WATCH_DIR, 'Services', f))
end

# Archivos de complicación: solo referencia en grupo, NO en compilación
complication_ref = complications_group.new_file(File.join(WATCH_DIR, 'Complications', 'ComplicationProvider.swift'))
puts "   ℹ️  ComplicationProvider.swift: referencia solo (requiere target separado)"

# Info.plist y entitlements: solo referencia, no compilar
watch_group.new_file(File.join(WATCH_DIR, 'Info.plist'))
watch_group.new_file(File.join(WATCH_DIR, 'GalapagosWatch.entitlements'))

# =============================================================================
# 5. Agregar frameworks necesarios
# =============================================================================
puts "🔗 Agregando frameworks..."

['HealthKit.framework', 'CoreLocation.framework'].each do |fw|
  ref = project.frameworks_group.new_file(fw)
  ref.set_last_known_file_type('wrapper.framework')
  watch_target.frameworks_build_phases.add_file_reference(ref)
  puts "   ✅ #{fw}"
end

# =============================================================================
# 6. Asociar el Watch target al Runner (companion app)
#    - Dependencia explícita: Runner depende de GalapagosWatch
#    - Fase de embed: copia GalapagosWatch.app en Runner bundle
# =============================================================================
puts "🔗 Asociando Watch target al iPhone target (Runner)..."

if runner_target
  # Dependencia
  container_proxy = project.new(Xcodeproj::Project::Object::PBXContainerItemProxy)
  container_proxy.container_portal = project.root_object.uuid
  container_proxy.proxy_type = '1'
  container_proxy.remote_global_id_string = watch_target.uuid
  container_proxy.remote_info = 'GalapagosWatch'

  dependency = project.new(Xcodeproj::Project::Object::PBXTargetDependency)
  dependency.target = watch_target
  dependency.target_proxy = container_proxy
  runner_target.dependencies << dependency
  puts "   ✅ Dependencia agregada (Runner → GalapagosWatch)"

  # Fase embed: Run Script (no CopyFiles) para evitar build cycle con Flutter Thin Binary.
  # PBXCopyFilesBuildPhase causa ciclo porque Xcode rastrea el árbol de directorios de
  # Runner.app/Info.plist, que incluye Watch/. Un Run Script con input/output explícitos
  # rompe el ciclo porque Xcode los trata como dependencias declaradas, no inferidas.
  embed_phase = runner_target.new_shell_script_build_phase('Embed Watch Content')
  embed_phase.shell_script = <<~'BASH'
    set -e
    # GalapagosWatch.app se construye en Debug-watchos/ (o Release-watchos/)
    # BUILT_PRODUCTS_DIR apunta a Debug-iphoneos/ — hay que subir un nivel.
    PRODUCTS_DIR="$(dirname "${BUILT_PRODUCTS_DIR}")"
    if [[ "${PLATFORM_NAME}" == *"simulator"* ]]; then
      WATCH_SRC="${PRODUCTS_DIR}/${CONFIGURATION}-watchsimulator/GalapagosWatch.app"
    else
      WATCH_SRC="${PRODUCTS_DIR}/${CONFIGURATION}-watchos/GalapagosWatch.app"
    fi
    WATCH_DST="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Watch/GalapagosWatch.app"
    echo "📦 Watch source: ${WATCH_SRC}"
    if [ -d "${WATCH_SRC}" ]; then
      mkdir -p "${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Watch"
      rsync -a --delete "${WATCH_SRC}/" "${WATCH_DST}/"
      echo "✅ GalapagosWatch.app embebida en Runner.app/Watch/"
    else
      echo "⚠️  GalapagosWatch.app no encontrada en ${WATCH_SRC}"
    fi
  BASH
  embed_phase.input_paths  = ['$(BUILT_PRODUCTS_DIR)/../$(CONFIGURATION)-watchos/GalapagosWatch.app']
  embed_phase.output_paths = ['$(TARGET_BUILD_DIR)/$(WRAPPER_NAME)/Watch/GalapagosWatch.app']
  puts "   ✅ Watch embebido en Runner (Run Script, sin build cycle)"
end

# =============================================================================
# 7. Guardar el proyecto y crear el scheme
# =============================================================================
puts "\n💾 Guardando proyecto..."
project.save

# Crear scheme para GalapagosWatch escribiendo el XML directamente
puts "📋 Creando scheme GalapagosWatch..."

watch_uuid = watch_target.uuid
scheme_xml = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <Scheme
     LastUpgradeVersion = "1510"
     version = "1.3">
     <BuildAction
        parallelizeBuildables = "YES"
        buildImplicitDependencies = "YES">
        <BuildActionEntries>
           <BuildActionEntry
              buildForTesting = "YES"
              buildForRunning = "YES"
              buildForProfiling = "YES"
              buildForArchiving = "YES"
              buildForAnalyzing = "YES">
              <BuildableReference
                 BuildableIdentifier = "primary"
                 BlueprintIdentifier = "#{watch_uuid}"
                 BuildableName = "GalapagosWatch.app"
                 BlueprintName = "GalapagosWatch"
                 ReferencedContainer = "container:Runner.xcodeproj">
              </BuildableReference>
           </BuildActionEntry>
        </BuildActionEntries>
     </BuildAction>
     <TestAction
        buildConfiguration = "Debug"
        selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
        selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
        shouldUseLaunchSchemeArgsEnv = "YES">
        <Testables>
        </Testables>
     </TestAction>
     <LaunchAction
        buildConfiguration = "Debug"
        selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
        selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
        launchStyle = "0"
        useCustomWorkingDirectory = "NO"
        ignoresPersistentStateOnLaunch = "NO"
        debugDocumentVersioning = "YES"
        debugServiceExtension = "internal"
        allowLocationSimulation = "YES">
        <BuildableProductRunnable
           runnableDebuggingMode = "0">
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{watch_uuid}"
              BuildableName = "GalapagosWatch.app"
              BlueprintName = "GalapagosWatch"
              ReferencedContainer = "container:Runner.xcodeproj">
           </BuildableReference>
        </BuildableProductRunnable>
     </LaunchAction>
     <ProfileAction
        buildConfiguration = "Release"
        shouldUseLaunchSchemeArgsEnv = "YES"
        savedToolIdentifier = ""
        useCustomWorkingDirectory = "NO"
        debugDocumentVersioning = "YES">
        <BuildableProductRunnable
           runnableDebuggingMode = "0">
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{watch_uuid}"
              BuildableName = "GalapagosWatch.app"
              BlueprintName = "GalapagosWatch"
              ReferencedContainer = "container:Runner.xcodeproj">
           </BuildableReference>
        </BuildableProductRunnable>
     </ProfileAction>
     <AnalyzeAction
        buildConfiguration = "Debug">
     </AnalyzeAction>
     <ArchiveAction
        buildConfiguration = "Release"
        revealArchiveInOrganizer = "YES">
     </ArchiveAction>
  </Scheme>
XML

schemes_dir = File.join(PROJECT_PATH, 'xcshareddata', 'xcschemes')
FileUtils.mkdir_p(schemes_dir)
scheme_path = File.join(schemes_dir, 'GalapagosWatch.xcscheme')
File.write(scheme_path, scheme_xml)
puts "   ✅ Scheme guardado en #{scheme_path}"

watch_uuid = watch_target.uuid
puts "\n✅ Target GalapagosWatch (#{watch_uuid}) listo en Runner.xcodeproj"
puts "\n📋 IMPORTANTE - UUID del target: #{watch_uuid}"
puts "\n📋 Próximos pasos:"
puts "   1. Abre Xcode: open ios/Runner.xcworkspace"
puts "   2. Selecciona scheme 'GalapagosWatch' + simulador Apple Watch"
puts "   3. Build & Run (Cmd+R)"
puts "   4. Para iPhone+Watch: selecciona scheme 'Runner' en iPhone"
puts "      (incluye GalapagosWatch como dependencia automáticamente)"
puts ""
