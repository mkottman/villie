.build-conf:
	@echo Tool collection not found.
	@echo Please specify existing tool collection in project properties
	@exit 1

# Clean Targets
.clean-conf: nbproject/qt-Release.mk
	$(MAKE) -f nbproject/qt-Release.mk distclean

# Subprojects
.clean-subprojects:
