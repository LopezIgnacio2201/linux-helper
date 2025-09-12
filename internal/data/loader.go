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

// loadModules loads the modules.txt and packages.txt files
func (dl *DataLoader) loadModules() error {
	// Load modules structure
	if err := dl.loadModulesStructure(); err != nil {
		return fmt.Errorf("failed to load modules structure: %w", err)
	}

	// Load packages
	if err := dl.loadPackages(); err != nil {
		return fmt.Errorf("failed to load packages: %w", err)
	}

	return nil
}

// loadModulesStructure loads the modules.txt file
func (dl *DataLoader) loadModulesStructure() error {
	filePath := "resources/modules.txt"
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open modules file: %w", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		
		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Parse format: MODULE_NAME:DIRECT_PACKAGES or MODULE_NAME:SUBMODULES
		parts := strings.Split(line, ":")
		if len(parts) != 2 {
			continue
		}

		moduleName := strings.TrimSpace(parts[0])
		moduleType := strings.TrimSpace(parts[1])

		// Initialize module
		module := Module{
			Name:       moduleName,
			Submodules: []Submodule{},
		}

		// If it's a direct packages module, create a "Packages" submodule
		if moduleType == "DIRECT_PACKAGES" {
			module.Submodules = append(module.Submodules, Submodule{
				Name:     "Packages",
				Packages: []Package{},
			})
		}

		dl.Modules[moduleName] = module
	}

	return scanner.Err()
}

// loadPackages loads the packages.txt file
func (dl *DataLoader) loadPackages() error {
	filePath := "resources/packages.txt"
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open packages file: %w", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		
		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Parse format: MODULE_NAME:SUBMODULE_NAME:PACKAGE_NAME
		parts := strings.Split(line, ":")
		if len(parts) != 3 {
			continue
		}

		moduleName := strings.TrimSpace(parts[0])
		submoduleName := strings.TrimSpace(parts[1])
		packageName := strings.TrimSpace(parts[2])

		// Find or create the submodule
		module, exists := dl.Modules[moduleName]
		if !exists {
			continue
		}

		// Find the submodule
		submoduleIndex := -1
		for i, submodule := range module.Submodules {
			if submodule.Name == submoduleName {
				submoduleIndex = i
				break
			}
		}

		// If submodule doesn't exist, create it
		if submoduleIndex == -1 {
			module.Submodules = append(module.Submodules, Submodule{
				Name:     submoduleName,
				Packages: []Package{},
			})
			submoduleIndex = len(module.Submodules) - 1
		}

		// Add package to submodule
		module.Submodules[submoduleIndex].Packages = append(module.Submodules[submoduleIndex].Packages, Package{
			Name: packageName,
		})

		// Update the module
		dl.Modules[moduleName] = module
	}

	return scanner.Err()
}

// loadProfiles loads the profiles.txt file
func (dl *DataLoader) loadProfiles() error {
	filePath := "resources/profiles.txt"
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open profiles file: %w", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	var currentProfile string
	var currentModules []string

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		
		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Parse format: PROFILE_NAME:MODULE_NAME
		parts := strings.Split(line, ":")
		if len(parts) != 2 {
			continue
		}

		profileName := strings.TrimSpace(parts[0])
		moduleName := strings.TrimSpace(parts[1])

		// If this is a new profile, save the previous one
		if currentProfile != "" && currentProfile != profileName {
			dl.Profiles[currentProfile] = Profile{
				Name:        currentProfile,
				CorePackages: []string{},
				UseCases:    make(map[string][]string),
				Modules:     currentModules,
			}
			currentModules = []string{}
		}

		currentProfile = profileName
		currentModules = append(currentModules, moduleName)
	}

	// Save the last profile
	if currentProfile != "" {
		dl.Profiles[currentProfile] = Profile{
			Name:        currentProfile,
			CorePackages: []string{},
			UseCases:    make(map[string][]string),
			Modules:     currentModules,
		}
	}

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
