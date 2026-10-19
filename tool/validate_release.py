import os,sys
required=['ANDROID_KEYSTORE_BASE64','ANDROID_KEYSTORE_PASSWORD','ANDROID_KEY_ALIAS','ANDROID_KEY_PASSWORD']
missing=[k for k in required if not os.environ.get(k)]
if missing:sys.exit('Missing signing configuration: '+', '.join(missing))
if os.environ.get('ENABLE_PRODUCTION_ADS','false')=='true':
 sys.exit('Production ads blocked: consent handling and live placements require device validation before release.')
print('Signing inputs present. Ads disabled for this release bundle. Store readiness requires owner review.')
