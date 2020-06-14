all: release
debug:
	xcodebuild -derivedDataPath $(PWD) -configuration Debug -scheme RsyncOSXsched
release:
	xcodebuild -derivedDataPath $(PWD) -configuration Release -scheme RsyncOSXsched
clean:
	rm -Rf Build
	rm -Rf ModuleCache.noindex
	rm -Rf info.plist
	rm -Rf Logs
