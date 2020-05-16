#! @python3@/bin/python3 -B
import importlib.util

install_spec = importlib.util.spec_from_file_location("install", "@installBootLoader@")
install = importlib.util.module_from_spec(install_spec)
install_spec.loader.exec_module(install)

install.BOOT_ENTRY = """title @bootName@{profile}
version Generation {generation} {description}
linux {kernel}
initrd {initrd}
options {kernel_params}
"""

install.main()
