package data

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// Package represents a single package
type Package struct {
	Name        string
	Description string
	Detailed    string
}

// Submodule represents a submodule with packages
type Submodule struct {
	Name     string
	Packages []Package
}

// Module represents a module with submodules
type Module struct {
	Name       string
	Submodules []Submodule
}

// Profile represents a user profile
type Profile struct {
	Name        string
	CorePackages []string
	UseCases    map[string][]string
	Modules     []string
}

// DataLoader handles loading all data files
type DataLoader struct {
	Modules  map[string]Module
	Profiles map[string]Profile
}

// NewDataLoader creates a new data loader
func NewDataLoader() *DataLoader {
	return &DataLoader{
		Modules:  make(map[string]Module),
		Profiles: make(map[string]Profile),
	}
}

// LoadAllData loads all data from the resources directory
func (dl *DataLoader) LoadAllData() error {
	// Load modules
	if err := dl.loadModules(); err != nil {
		return fmt.Errorf("failed to load modules: %w", err)
	}

	// Load profiles
	if err := dl.loadProfiles(); err != nil {
		return fmt.Errorf("failed to load profiles: %w", err)
	}

	return nil
}

// loadModules loads the modules-and-packages.txt file
func (dl *DataLoader) loadModules() error {
	filePath := "resources/modules/modules-and-packages.txt"
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open modules file: %w", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var currentModule Module
	var currentSubmodule Submodule
	var inModule, inSubmodule bool

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		
		// Skip empty lines
		if line == "" {
			continue
		}

		// Skip comment lines that are not headers
		if strings.HasPrefix(line, "#") && !strings.HasPrefix(line, "## ") && !strings.HasPrefix(line, "### ") {
			continue
		}

		// Check for module header (## MODULE: NAME format)
		if strings.HasPrefix(line, "## ") && strings.Contains(line, "MODULE:") {
			// Save previous module if exists
			if inModule {
				dl.Modules[currentModule.Name] = currentModule
			}
			
			// Start new module
			moduleName := strings.TrimSpace(strings.TrimPrefix(line, "## "))
			moduleName = strings.TrimSpace(strings.TrimPrefix(moduleName, "MODULE:"))
			currentModule = Module{Name: moduleName, Submodules: []Submodule{}}
			inModule = true
			inSubmodule = false
			continue
		}

		// Check for module header (## NAME MODULE format)
		if strings.HasPrefix(line, "## ") && strings.HasSuffix(line, " MODULE") {
			// Save previous module if exists
			if inModule {
				dl.Modules[currentModule.Name] = currentModule
			}
			
			// Start new module
			moduleName := strings.TrimSpace(strings.TrimSuffix(line, " MODULE"))
			moduleName = strings.TrimSpace(strings.TrimPrefix(moduleName, "## "))
			currentModule = Module{Name: moduleName, Submodules: []Submodule{}}
			inModule = true
			inSubmodule = false
			continue
		}

		// Check for submodule header (### SUBMODULE: NAME format)
		if strings.HasPrefix(line, "### SUBMODULE:") {
			// Save previous submodule if exists
			if inSubmodule {
				currentModule.Submodules = append(currentModule.Submodules, currentSubmodule)
			}
			
			// Start new submodule
			submoduleName := strings.TrimSpace(strings.TrimPrefix(line, "### SUBMODULE:"))
			currentSubmodule = Submodule{Name: submoduleName, Packages: []Package{}}
			inSubmodule = true
			continue
		}

		// Check for submodule header (### NAME format)
		if strings.HasPrefix(line, "### ") && !strings.Contains(line, "SUBMODULE:") {
			// Save previous submodule if exists
			if inSubmodule {
				currentModule.Submodules = append(currentModule.Submodules, currentSubmodule)
			}
			
			// Start new submodule
			submoduleName := strings.TrimSpace(strings.TrimPrefix(line, "### "))
			currentSubmodule = Submodule{Name: submoduleName, Packages: []Package{}}
			inSubmodule = true
			continue
		}

		// Check for package (non-header line in submodule)
		if inSubmodule && !strings.HasPrefix(line, "#") && !strings.HasPrefix(line, "=") {
			packageName := strings.TrimSpace(line)
			if packageName != "" {
				currentSubmodule.Packages = append(currentSubmodule.Packages, Package{Name: packageName})
			}
		}
	}

	// Save last module and submodule
	if inSubmodule {
		currentModule.Submodules = append(currentModule.Submodules, currentSubmodule)
	}
	if inModule {
		dl.Modules[currentModule.Name] = currentModule
	}

	return scanner.Err()
}

// loadProfiles loads the profile files
func (dl *DataLoader) loadProfiles() error {
	// Load newbie profile
	if err := dl.loadNewbieProfile(); err != nil {
		return fmt.Errorf("failed to load newbie profile: %w", err)
	}

	// Load common user profile
	if err := dl.loadCommonUserProfile(); err != nil {
		return fmt.Errorf("failed to load common user profile: %w", err)
	}

	// Load power user profile
	if err := dl.loadPowerUserProfile(); err != nil {
		return fmt.Errorf("failed to load power user profile: %w", err)
	}

	return nil
}

// loadNewbieProfile loads the newbie profile
func (dl *DataLoader) loadNewbieProfile() error {
	filePath := "resources/packages/package-lists-newbie.txt"
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open newbie profile: %w", err)
	}
	defer file.Close()

	profile := Profile{
		Name:         "newbie",
		CorePackages: []string{},
		UseCases:     make(map[string][]string),
		Modules:      []string{},
	}

	scanner := bufio.NewScanner(file)
	var currentSection string
	var inCorePackages, inUseCases bool

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		
		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Check for core packages section
		if strings.Contains(line, "CORE PACKAGES") {
			inCorePackages = true
			inUseCases = false
			currentSection = ""
			continue
		}

		// Check for use cases section
		if strings.Contains(line, "USE CASE SPECIFIC PACKAGES") {
			inCorePackages = false
			inUseCases = true
			currentSection = ""
			continue
		}

		// Check for use case header
		if inUseCases && strings.HasPrefix(line, "## ") && strings.Contains(line, "USE CASE") {
			currentSection = strings.TrimSpace(strings.TrimPrefix(line, "## "))
			currentSection = strings.TrimSpace(strings.TrimPrefix(currentSection, "USE CASE"))
			profile.UseCases[currentSection] = []string{}
			continue
		}

		// Add packages to current section
		if !strings.HasPrefix(line, "#") && !strings.HasPrefix(line, "=") && line != "" {
			if inCorePackages {
				profile.CorePackages = append(profile.CorePackages, line)
			} else if inUseCases && currentSection != "" {
				profile.UseCases[currentSection] = append(profile.UseCases[currentSection], line)
			}
		}
	}

	dl.Profiles["newbie"] = profile
	return scanner.Err()
}

// loadCommonUserProfile loads the common user profile
func (dl *DataLoader) loadCommonUserProfile() error {
	filePath := "resources/packages/common-user-menu.txt"
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open common user profile: %w", err)
	}
	defer file.Close()

	profile := Profile{
		Name:        "common",
		CorePackages: []string{},
		UseCases:    make(map[string][]string),
		Modules:     []string{},
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		
		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Extract module names (lines starting with "- ")
		if strings.HasPrefix(line, "- ") && !strings.Contains(line, "-->") {
			moduleName := strings.TrimSpace(strings.TrimPrefix(line, "- "))
			profile.Modules = append(profile.Modules, moduleName)
		}
	}

	dl.Profiles["common"] = profile
	return scanner.Err()
}

// loadPowerUserProfile loads the power user profile
func (dl *DataLoader) loadPowerUserProfile() error {
	filePath := "resources/packages/poweruser-menu.txt"
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open power user profile: %w", err)
	}
	defer file.Close()

	profile := Profile{
		Name:        "poweruser",
		CorePackages: []string{},
		UseCases:    make(map[string][]string),
		Modules:     []string{},
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		
		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Extract module names (lines starting with "- ")
		if strings.HasPrefix(line, "- ") && !strings.Contains(line, "-->") {
			moduleName := strings.TrimSpace(strings.TrimPrefix(line, "- "))
			profile.Modules = append(profile.Modules, moduleName)
		}
	}

	dl.Profiles["poweruser"] = profile
	return scanner.Err()
}

// GetModule returns a module by name
func (dl *DataLoader) GetModule(name string) (Module, bool) {
	module, exists := dl.Modules[name]
	return module, exists
}

// GetProfile returns a profile by name
func (dl *DataLoader) GetProfile(name string) (Profile, bool) {
	profile, exists := dl.Profiles[name]
	return profile, exists
}

// ListModules returns all available modules
func (dl *DataLoader) ListModules() []string {
	var modules []string
	for name := range dl.Modules {
		modules = append(modules, name)
	}
	return modules
}

// ListProfiles returns all available profiles
func (dl *DataLoader) ListProfiles() []string {
	var profiles []string
	for name := range dl.Profiles {
		profiles = append(profiles, name)
	}
	return profiles
}
