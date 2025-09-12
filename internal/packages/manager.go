package packages

import (
	"fmt"
	"os/exec"
	"strings"
)

// PackageManager handles package installation operations
type PackageManager struct {
	aurHelper string
}

// NewPackageManager creates a new package manager instance
func NewPackageManager() *PackageManager {
	pm := &PackageManager{}
	pm.detectAURHelper()
	return pm
}

// detectAURHelper detects available AUR helper (paru > yay > install paru)
func (pm *PackageManager) detectAURHelper() {
	// Check for paru first (preferred)
	if pm.isCommandAvailable("paru") {
		pm.aurHelper = "paru"
		return
	}

	// Check for yay as fallback
	if pm.isCommandAvailable("yay") {
		pm.aurHelper = "yay"
		return
	}

	// If neither is available, we'll install paru
	pm.aurHelper = "paru"
}

// isCommandAvailable checks if a command is available in PATH
func (pm *PackageManager) isCommandAvailable(command string) bool {
	_, err := exec.LookPath(command)
	return err == nil
}

// InstallPackages installs a list of packages
func (pm *PackageManager) InstallPackages(packageNames []string) error {
	if len(packageNames) == 0 {
		return fmt.Errorf("no packages to install")
	}

	// Separate AUR and official packages
	aurPackages, officialPackages := pm.categorizePackages(packageNames)

	// Install official packages first
	if len(officialPackages) > 0 {
		if err := pm.installOfficialPackages(officialPackages); err != nil {
			return fmt.Errorf("failed to install official packages: %w", err)
		}
	}

	// Install AUR packages
	if len(aurPackages) > 0 {
		if err := pm.installAURPackages(aurPackages); err != nil {
			return fmt.Errorf("failed to install AUR packages: %w", err)
		}
	}

	return nil
}

// categorizePackages separates packages into official and AUR packages
func (pm *PackageManager) categorizePackages(packageNames []string) ([]string, []string) {
	var aurPackages []string
	var officialPackages []string

	for _, pkg := range packageNames {
		// Check if package exists in official repos
		if pm.isPackageInOfficialRepos(pkg) {
			officialPackages = append(officialPackages, pkg)
		} else {
			aurPackages = append(aurPackages, pkg)
		}
	}

	return aurPackages, officialPackages
}

// isPackageInOfficialRepos checks if a package exists in official repositories
func (pm *PackageManager) isPackageInOfficialRepos(packageName string) bool {
	cmd := exec.Command("pacman", "-Si", packageName)
	err := cmd.Run()
	return err == nil
}

// installOfficialPackages installs packages from official repositories
func (pm *PackageManager) installOfficialPackages(packageNames []string) error {
	args := append([]string{"pacman", "-S", "--noconfirm"}, packageNames...)
	cmd := exec.Command("sudo", args...)

	// Capture output instead of redirecting to avoid terminal corruption
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("pacman installation failed: %s", string(output))
	}

	return nil
}

// installAURPackages installs packages from AUR
func (pm *PackageManager) installAURPackages(packageNames []string) error {
	// Ensure AUR helper is available
	if !pm.isCommandAvailable(pm.aurHelper) {
		if err := pm.installParu(); err != nil {
			return fmt.Errorf("failed to install paru: %w", err)
		}
	}

	// Install AUR packages
	args := append([]string{"-S", "--noconfirm"}, packageNames...)
	cmd := exec.Command(pm.aurHelper, args...)

	// Capture output instead of redirecting to avoid terminal corruption
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("%s installation failed: %s", pm.aurHelper, string(output))
	}

	return nil
}

// installParu installs paru AUR helper
func (pm *PackageManager) installParu() error {
	// Install dependencies
	depsCmd := exec.Command("sudo", "pacman", "-S", "--noconfirm", "base-devel", "git")
	if err := depsCmd.Run(); err != nil {
		return fmt.Errorf("failed to install dependencies: %w", err)
	}

	// Clone and build paru
	cloneCmd := exec.Command("git", "clone", "https://aur.archlinux.org/paru.git", "/tmp/paru")
	if err := cloneCmd.Run(); err != nil {
		return fmt.Errorf("failed to clone paru: %w", err)
	}

	// Build and install paru
	buildCmd := exec.Command("bash", "-c", "cd /tmp/paru && makepkg -si --noconfirm")
	if err := buildCmd.Run(); err != nil {
		return fmt.Errorf("failed to build paru: %w", err)
	}

	// Clean up
	cleanupCmd := exec.Command("rm", "-rf", "/tmp/paru")
	cleanupCmd.Run()

	return nil
}

// GetPackageInfo returns information about a package
func (pm *PackageManager) GetPackageInfo(packageName string) (string, error) {
	// Try official repos first
	cmd := exec.Command("pacman", "-Si", packageName)
	output, err := cmd.CombinedOutput()
	if err == nil {
		return string(output), nil
	}

	// Try AUR if available
	if pm.isCommandAvailable(pm.aurHelper) {
		cmd = exec.Command(pm.aurHelper, "-Si", packageName)
		output, err = cmd.CombinedOutput()
		if err == nil {
			return string(output), nil
		}
	}

	return "", fmt.Errorf("package information not found for %s", packageName)
}

// GetInstalledPackages returns a list of installed packages
func (pm *PackageManager) GetInstalledPackages() ([]string, error) {
	cmd := exec.Command("pacman", "-Qq")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to get installed packages: %w", err)
	}

	packages := strings.Split(strings.TrimSpace(string(output)), "\n")
	return packages, nil
}

// IsPackageInstalled checks if a package is already installed
func (pm *PackageManager) IsPackageInstalled(packageName string) bool {
	cmd := exec.Command("pacman", "-Q", packageName)
	err := cmd.Run()
	return err == nil
}
