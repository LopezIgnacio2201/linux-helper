package main

import (
	"fmt"
	"os"
	"strings"

	"linux-package-manager/internal/data"
	"linux-package-manager/internal/packages"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Helper functions
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

// Window-like Styling
var (
	// Color Palette
	primaryColor   = lipgloss.Color("#00D4AA") // Teal
	secondaryColor = lipgloss.Color("#7C3AED") // Purple
	accentColor    = lipgloss.Color("#F59E0B") // Amber
	textColor      = lipgloss.Color("#F8FAFC") // Light gray
	mutedColor     = lipgloss.Color("#64748B") // Gray
	borderColor    = lipgloss.Color("#475569") // Slate

	// Window Styles
	titleStyle = lipgloss.NewStyle().
			Foreground(primaryColor).
			Bold(true).
			Margin(2, 0, 1, 0)

	windowStyle = lipgloss.NewStyle().
			Border(lipgloss.DoubleBorder()).
			BorderForeground(primaryColor).
			Padding(1, 2).
			Margin(1, 0)

	headerStyle = lipgloss.NewStyle().
			Foreground(secondaryColor).
			Bold(true).
			Margin(0, 0, 1, 0)

	selectedStyle = lipgloss.NewStyle().
			Foreground(accentColor).
			Bold(true).
			Background(lipgloss.Color("#1E293B")).
			Padding(0, 1)

	unselectedStyle = lipgloss.NewStyle().
			Foreground(textColor).
			Padding(0, 1)

	controlsStyle = lipgloss.NewStyle().
			Foreground(mutedColor).
			Italic(true).
			Margin(1, 0, 0, 0).
			Align(lipgloss.Center)
)

type model struct {
	message        string
	dataLoader     *data.DataLoader
	packageManager *packages.PackageManager
	modules        []string
	profiles       []string

	// Navigation state
	currentView       string // "profile_selection", "module_selection", "submodule_selection", "package_selection"
	selectedProfile   int
	selectedModule    int
	selectedSubmodule int
	selectedPackage   int

	// Package selection state
	selectedPackages map[string]bool // Track which packages are selected
}

func initialModel() model {
	// Initialize data loader
	loader := data.NewDataLoader()

	// Load all data
	if err := loader.LoadAllData(); err != nil {
		return model{
			message: fmt.Sprintf("Error loading data: %v", err),
		}
	}

	// Initialize package manager
	packageManager := packages.NewPackageManager()

	return model{
		message:           "Linux Package Manager TUI",
		dataLoader:        loader,
		packageManager:    packageManager,
		modules:           loader.ListModules(),
		profiles:          loader.ListProfiles(),
		currentView:       "profile_selection",
		selectedProfile:   0,
		selectedModule:    0,
		selectedSubmodule: 0,
		selectedPackage:   0,
		selectedPackages:  make(map[string]bool),
	}
}

func (m model) Init() tea.Cmd {
	return tea.ClearScreen
}

// installAllSelectedPackages starts the installation process for all selected packages across all modules
func (m model) installAllSelectedPackages() (tea.Model, tea.Cmd) {
	// Get all selected packages from all modules and submodules
	var packagesToInstall []string
	for packageName, isSelected := range m.selectedPackages {
		if isSelected {
			packagesToInstall = append(packagesToInstall, packageName)
		}
	}

	if len(packagesToInstall) == 0 {
		// No packages selected, just return without doing anything
		return m, nil
	}

	// Exit TUI and run installation in clean terminal state
	return m, tea.Quit
}

// Message types for installation (no longer used but kept for compatibility)
type installationErrorMsg struct {
	error error
}

type installationCompleteMsg struct{}

// getCurrentPackages returns the packages for the currently selected submodule
func (m model) getCurrentPackages() []data.Package {
	profile, exists := m.dataLoader.GetProfile(m.profiles[m.selectedProfile])
	if !exists {
		return []data.Package{}
	}

	var moduleName string
	if m.profiles[m.selectedProfile] == "newbie" {
		// For newbie, get use case name
		useCaseIndex := 0
		for useCase := range profile.UseCases {
			if useCaseIndex == m.selectedModule {
				moduleName = useCase
				break
			}
			useCaseIndex++
		}
	} else {
		// For other profiles, get module name
		moduleName = profile.Modules[m.selectedModule]
	}

	module, moduleExists := m.dataLoader.GetModule(moduleName)
	if !moduleExists || m.selectedSubmodule >= len(module.Submodules) {
		return []data.Package{}
	}

	return module.Submodules[m.selectedSubmodule].Packages
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q":
			return m, tea.Quit
		case "up":
			if m.currentView == "profile_selection" {
				m.selectedProfile = max(0, m.selectedProfile-1)
			} else if m.currentView == "module_selection" {
				// Navigate up in module selection
				m.selectedModule = max(0, m.selectedModule-1)
			} else if m.currentView == "submodule_selection" {
				m.selectedSubmodule = max(0, m.selectedSubmodule-1)
			} else if m.currentView == "package_selection" {
				m.selectedPackage = max(0, m.selectedPackage-1)
			}
		case "down":
			if m.currentView == "profile_selection" {
				m.selectedProfile = min(len(m.profiles)-1, m.selectedProfile+1)
			} else if m.currentView == "module_selection" {
				profile, exists := m.dataLoader.GetProfile(m.profiles[m.selectedProfile])
				if exists {
					if m.profiles[m.selectedProfile] == "newbie" {
						// Newbie profile uses use cases
						m.selectedModule = min(len(profile.UseCases)-1, m.selectedModule+1)
					} else {
						// Other profiles use modules + install option
						m.selectedModule = min(len(profile.Modules), m.selectedModule+1)
					}
				}
			} else if m.currentView == "submodule_selection" {
				// Get current module and its submodules
				profile, exists := m.dataLoader.GetProfile(m.profiles[m.selectedProfile])
				if exists {
					var moduleName string
					if m.profiles[m.selectedProfile] == "newbie" {
						// For newbie, get use case name
						useCaseIndex := 0
						for useCase := range profile.UseCases {
							if useCaseIndex == m.selectedModule {
								moduleName = useCase
								break
							}
							useCaseIndex++
						}
					} else {
						// For other profiles, get module name
						moduleName = profile.Modules[m.selectedModule]
					}

					module, moduleExists := m.dataLoader.GetModule(moduleName)
					if moduleExists {
						m.selectedSubmodule = min(len(module.Submodules)-1, m.selectedSubmodule+1)
					}
				}
			} else if m.currentView == "package_selection" {
				// Get current packages count
				packages := m.getCurrentPackages()
				m.selectedPackage = min(len(packages)-1, m.selectedPackage+1)
			}
		case "left":
			// Navigate back (same as escape)
			if m.currentView == "module_selection" {
				// Go back to profile selection
				m.currentView = "profile_selection"
				return m, tea.ClearScreen
			} else if m.currentView == "submodule_selection" {
				// Go back to module selection
				m.currentView = "module_selection"
				return m, tea.ClearScreen
			} else if m.currentView == "package_selection" {
				// Check if we came from a module with direct packages or submodules
				profile, exists := m.dataLoader.GetProfile(m.profiles[m.selectedProfile])
				if exists {
					var moduleName string
					if m.profiles[m.selectedProfile] == "newbie" {
						// For newbie, get use case name
						useCaseIndex := 0
						for useCase := range profile.UseCases {
							if useCaseIndex == m.selectedModule {
								moduleName = useCase
								break
							}
							useCaseIndex++
						}
					} else {
						// For other profiles, get module name
						moduleName = profile.Modules[m.selectedModule]
					}

					module, moduleExists := m.dataLoader.GetModule(moduleName)
					if moduleExists {
						// If module has only one submodule called "Packages", go back to module selection
						if len(module.Submodules) == 1 && module.Submodules[0].Name == "Packages" {
							m.currentView = "module_selection"
							return m, tea.ClearScreen
						} else {
							// Otherwise, go back to submodule selection
							m.currentView = "submodule_selection"
							return m, tea.ClearScreen
						}
					}
				}
			}
		case "right":
			// Navigate forward (same as enter)
			if m.currentView == "profile_selection" {
				// Move to module selection for selected profile
				m.currentView = "module_selection"
				m.selectedModule = 0
				return m, tea.ClearScreen
			} else if m.currentView == "module_selection" {
				// Check if module has submodules or direct packages
				profile, exists := m.dataLoader.GetProfile(m.profiles[m.selectedProfile])
				if exists {
					var moduleName string
					if m.profiles[m.selectedProfile] == "newbie" {
						// For newbie, get use case name
						useCaseIndex := 0
						for useCase := range profile.UseCases {
							if useCaseIndex == m.selectedModule {
								moduleName = useCase
								break
							}
							useCaseIndex++
						}
					} else {
						// For other profiles, get module name
						moduleName = profile.Modules[m.selectedModule]
					}

					module, moduleExists := m.dataLoader.GetModule(moduleName)
					if moduleExists {
						// If module has only one submodule called "Packages", skip to package selection
						if len(module.Submodules) == 1 && module.Submodules[0].Name == "Packages" {
							m.currentView = "package_selection"
							m.selectedSubmodule = 0
							m.selectedPackage = 0
							return m, tea.ClearScreen
						} else {
							// Otherwise, go to submodule selection
							m.currentView = "submodule_selection"
							m.selectedSubmodule = 0
							return m, tea.ClearScreen
						}
					}
				}
			} else if m.currentView == "submodule_selection" {
				// Move to package selection for selected submodule
				m.currentView = "package_selection"
				m.selectedPackage = 0
				return m, tea.ClearScreen
			}
		case "enter":
			if m.currentView == "profile_selection" {
				// Move to module selection for selected profile
				m.currentView = "module_selection"
				m.selectedModule = 0
				return m, tea.ClearScreen
			} else if m.currentView == "module_selection" {
				// Check if module has submodules or direct packages
				profile, exists := m.dataLoader.GetProfile(m.profiles[m.selectedProfile])
				if exists {
					if m.profiles[m.selectedProfile] == "newbie" {
						// For newbie, get use case name
						useCaseIndex := 0
						for useCase := range profile.UseCases {
							if useCaseIndex == m.selectedModule {
								moduleName := useCase
								module, moduleExists := m.dataLoader.GetModule(moduleName)
								if moduleExists {
									// If module has only one submodule called "Packages", skip to package selection
									if len(module.Submodules) == 1 && module.Submodules[0].Name == "Packages" {
										m.currentView = "package_selection"
										m.selectedSubmodule = 0
										m.selectedPackage = 0
										return m, tea.ClearScreen
									} else {
										// Otherwise, go to submodule selection
										m.currentView = "submodule_selection"
										m.selectedSubmodule = 0
										return m, tea.ClearScreen
									}
								}
								break
							}
							useCaseIndex++
						}
					} else {
						// For other profiles, check if install option is selected
						if m.selectedModule == len(profile.Modules) {
							// User selected the install option
							return m.installAllSelectedPackages()
						} else {
							// User selected a module
							moduleName := profile.Modules[m.selectedModule]
							module, moduleExists := m.dataLoader.GetModule(moduleName)
							if moduleExists {
								// If module has only one submodule called "Packages", skip to package selection
								if len(module.Submodules) == 1 && module.Submodules[0].Name == "Packages" {
									m.currentView = "package_selection"
									m.selectedSubmodule = 0
									m.selectedPackage = 0
									return m, tea.ClearScreen
								} else {
									// Otherwise, go to submodule selection
									m.currentView = "submodule_selection"
									m.selectedSubmodule = 0
									return m, tea.ClearScreen
								}
							}
						}
					}
				}
			} else if m.currentView == "submodule_selection" {
				// Move to package selection for selected submodule
				m.currentView = "package_selection"
				m.selectedPackage = 0
				return m, tea.ClearScreen
			} else if m.currentView == "package_selection" {
				// No special enter handling in package selection
				// User can only select packages with TAB
			}
		case "esc":
			if m.currentView == "module_selection" {
				// Go back to profile selection
				m.currentView = "profile_selection"
				return m, tea.ClearScreen
			} else if m.currentView == "submodule_selection" {
				// Go back to module selection
				m.currentView = "module_selection"
				return m, tea.ClearScreen
			} else if m.currentView == "package_selection" {
				// Go back to submodule selection
				m.currentView = "submodule_selection"
				return m, tea.ClearScreen
			}
		case "tab":
			// Toggle package selection
			if m.currentView == "package_selection" {
				packages := m.getCurrentPackages()
				if m.selectedPackage < len(packages) {
					packageName := packages[m.selectedPackage].Name
					m.selectedPackages[packageName] = !m.selectedPackages[packageName]
				}
			}
		}
	}
	return m, nil
}

func (m model) View() string {
	var content strings.Builder

	// Clear screen and add title with top padding
	content.WriteString("\033[2J\033[H") // Clear screen and move cursor to top
	content.WriteString(titleStyle.Render("🚀 Linux Package Manager TUI"))
	content.WriteString("\n")

	// Window content (inside the bordered box)
	var windowContent strings.Builder

	if m.currentView == "profile_selection" {
		// Profile selection inside window
		if len(m.profiles) > 0 {
			windowContent.WriteString(headerStyle.Render("👤 Select a profile"))
			windowContent.WriteString("\n\n")

			for i, profile := range m.profiles {
				profileIcon := "🔰"
				if profile == "common" {
					profileIcon = "⚡"
				} else if profile == "poweruser" {
					profileIcon = "🔥"
				}

				if i == m.selectedProfile {
					windowContent.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s %s", profileIcon, profile)))
				} else {
					windowContent.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s %s", profileIcon, profile)))
				}
				windowContent.WriteString("\n")
			}
		}
	} else if m.currentView == "module_selection" {
		// Module selection inside window
		selectedProfileName := m.profiles[m.selectedProfile]
		profileIcon := "🔰"
		if selectedProfileName == "common" {
			profileIcon = "⚡"
		} else if selectedProfileName == "poweruser" {
			profileIcon = "🔥"
		}

		windowContent.WriteString(headerStyle.Render(fmt.Sprintf("%s Profile: %s", profileIcon, selectedProfileName)))
		windowContent.WriteString("\n\n")

		// Get available modules for this profile
		profile, exists := m.dataLoader.GetProfile(selectedProfileName)
		if exists {
			if selectedProfileName == "newbie" {
				// Newbie profile shows use cases
				windowContent.WriteString(headerStyle.Render("🎯 Select a use case"))
				windowContent.WriteString("\n\n")

				useCaseIndex := 0
				for useCase := range profile.UseCases {
					useCaseIcon := "🎮"
					if strings.Contains(strings.ToLower(useCase), "gaming") {
						useCaseIcon = "🎮"
					} else if strings.Contains(strings.ToLower(useCase), "programming") {
						useCaseIcon = "💻"
					} else if strings.Contains(strings.ToLower(useCase), "editing") {
						useCaseIcon = "🎨"
					} else if strings.Contains(strings.ToLower(useCase), "cybersecurity") {
						useCaseIcon = "🔒"
					} else if strings.Contains(strings.ToLower(useCase), "day") {
						useCaseIcon = "📅"
					}

					if useCaseIndex == m.selectedModule {
						windowContent.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s %s", useCaseIcon, useCase)))
					} else {
						windowContent.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s %s", useCaseIcon, useCase)))
					}
					windowContent.WriteString("\n")
					useCaseIndex++
				}
			} else {
				// Other profiles show modules
				windowContent.WriteString(headerStyle.Render("📦 Available modules"))
				windowContent.WriteString("\n\n")

				for i, moduleName := range profile.Modules {
					moduleIcon := "📦"
					if strings.Contains(strings.ToLower(moduleName), "browser") {
						moduleIcon = "🌐"
					} else if strings.Contains(strings.ToLower(moduleName), "terminal") {
						moduleIcon = "💻"
					} else if strings.Contains(strings.ToLower(moduleName), "gaming") {
						moduleIcon = "🎮"
					} else if strings.Contains(strings.ToLower(moduleName), "development") {
						moduleIcon = "⚙️"
					} else if strings.Contains(strings.ToLower(moduleName), "cybersecurity") {
						moduleIcon = "🔒"
					} else if strings.Contains(strings.ToLower(moduleName), "privacy") {
						moduleIcon = "🛡️"
					}

					if i == m.selectedModule {
						windowContent.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s %s", moduleIcon, moduleName)))
					} else {
						windowContent.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s %s", moduleIcon, moduleName)))
					}
					windowContent.WriteString("\n")
				}

				// Add global install option
				windowContent.WriteString("\n")
				if m.selectedModule == len(profile.Modules) {
					windowContent.WriteString(selectedStyle.Render("▶ 🚀 Install all selected packages"))
				} else {
					windowContent.WriteString(unselectedStyle.Render("  🚀 Install all selected packages"))
				}
			}
		}
	} else if m.currentView == "submodule_selection" {
		// Submodule selection inside window
		selectedProfileName := m.profiles[m.selectedProfile]
		windowContent.WriteString(headerStyle.Render(fmt.Sprintf("Profile: %s", selectedProfileName)))
		windowContent.WriteString("\n\n")

		// Get current module name
		profile, exists := m.dataLoader.GetProfile(selectedProfileName)
		if exists {
			var moduleName string
			if selectedProfileName == "newbie" {
				// For newbie, get use case name
				useCaseIndex := 0
				for useCase := range profile.UseCases {
					if useCaseIndex == m.selectedModule {
						moduleName = useCase
						break
					}
					useCaseIndex++
				}
			} else {
				// For other profiles, get module name
				moduleName = profile.Modules[m.selectedModule]
			}

			windowContent.WriteString(headerStyle.Render(fmt.Sprintf("📁 Module: %s", moduleName)))
			windowContent.WriteString("\n\n")

			// Get submodules
			module, moduleExists := m.dataLoader.GetModule(moduleName)
			if moduleExists && len(module.Submodules) > 0 {
				windowContent.WriteString(headerStyle.Render("🔧 Available submodules"))
				windowContent.WriteString("\n\n")

				for i, submodule := range module.Submodules {
					submoduleIcon := "🔧"
					if strings.Contains(strings.ToLower(submodule.Name), "terminal") {
						submoduleIcon = "💻"
					} else if strings.Contains(strings.ToLower(submodule.Name), "shell") {
						submoduleIcon = "🐚"
					} else if strings.Contains(strings.ToLower(submodule.Name), "editor") {
						submoduleIcon = "✏️"
					} else if strings.Contains(strings.ToLower(submodule.Name), "language") {
						submoduleIcon = "📝"
					}

					if i == m.selectedSubmodule {
						windowContent.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s %s", submoduleIcon, submodule.Name)))
					} else {
						windowContent.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s %s", submoduleIcon, submodule.Name)))
					}
					windowContent.WriteString("\n")
				}
			} else {
				windowContent.WriteString(unselectedStyle.Render("ℹ️ No submodules available"))
			}
		}
	} else if m.currentView == "package_selection" {
		// Package selection inside window
		selectedProfileName := m.profiles[m.selectedProfile]
		windowContent.WriteString(headerStyle.Render(fmt.Sprintf("Profile: %s", selectedProfileName)))
		windowContent.WriteString("\n\n")

		// Get current module and submodule names
		profile, exists := m.dataLoader.GetProfile(selectedProfileName)
		if exists {
			var moduleName string
			if selectedProfileName == "newbie" {
				// For newbie, get use case name
				useCaseIndex := 0
				for useCase := range profile.UseCases {
					if useCaseIndex == m.selectedModule {
						moduleName = useCase
						break
					}
					useCaseIndex++
				}
			} else {
				// For other profiles, get module name
				moduleName = profile.Modules[m.selectedModule]
			}

			module, moduleExists := m.dataLoader.GetModule(moduleName)
			if moduleExists && m.selectedSubmodule < len(module.Submodules) {
				submoduleName := module.Submodules[m.selectedSubmodule].Name
				windowContent.WriteString(headerStyle.Render(fmt.Sprintf("📦 %s → %s", moduleName, submoduleName)))
				windowContent.WriteString("\n\n")

				// Get packages
				packages := module.Submodules[m.selectedSubmodule].Packages
				if len(packages) > 0 {
					windowContent.WriteString(headerStyle.Render("📋 Available packages"))
					windowContent.WriteString("\n\n")

					for i, pkg := range packages {
						// Check if package is selected
						isSelected := m.selectedPackages[pkg.Name]
						selectionIcon := "☐"
						if isSelected {
							selectionIcon = "✓"
						}

						if i == m.selectedPackage {
							windowContent.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s %s", selectionIcon, pkg.Name)))
						} else {
							windowContent.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s %s", selectionIcon, pkg.Name)))
						}
						windowContent.WriteString("\n")
					}

					// No install option in package selection - it's now global
				} else {
					windowContent.WriteString(unselectedStyle.Render("ℹ️ No packages available"))
				}
			}
		}
	}

	// Apply window border to content
	content.WriteString(windowStyle.Render(windowContent.String()))
	content.WriteString("\n")

	// Simplified controls at the bottom (outside the window)
	var controls string
	if m.currentView == "package_selection" {
		controls = "↑↓ Navigate • ←→ Menu • ⇥ Select • ⎋ Back • q Quit"
	} else if m.currentView == "module_selection" {
		controls = "↑↓ Navigate • ←→ Menu • ⏎ Select/Install • ⎋ Back • q Quit"
	} else {
		controls = "↑↓ Navigate • ←→ Menu • ⏎ Select • ⎋ Back • q Quit"
	}
	content.WriteString(controlsStyle.Render(controls))

	return content.String()
}

func main() {
	// Check if we should run installation
	if len(os.Args) > 1 && os.Args[1] == "--install" {
		runInstallationMode()
		return
	}

	p := tea.NewProgram(initialModel())
	finalModel, err := p.Run()
	if err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}

	// Check if we need to run installation after TUI exits
	if m, ok := finalModel.(model); ok {
		// Get selected packages
		var packagesToInstall []string
		for packageName, isSelected := range m.selectedPackages {
			if isSelected {
				packagesToInstall = append(packagesToInstall, packageName)
			}
		}

		if len(packagesToInstall) > 0 {
			runInstallation(packagesToInstall)
		}
	}
}

// runInstallationMode runs installation directly (for --install flag)
func runInstallationMode() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: linux-package-manager --install <package1> <package2> ...")
		os.Exit(1)
	}

	packages := os.Args[2:]
	runInstallation(packages)
}

// runInstallation runs the actual package installation
func runInstallation(packagesToInstall []string) {
	fmt.Println("🚀 Linux Package Manager - Installation Mode")
	fmt.Println("=============================================")
	fmt.Printf("Packages to install: %v\n\n", packagesToInstall)

	// Initialize package manager
	packageManager := packages.NewPackageManager()

	// Run installation
	fmt.Println("Starting installation...")
	err := packageManager.InstallPackages(packagesToInstall)

	if err != nil {
		fmt.Printf("\n❌ Installation failed: %v\n", err)
		os.Exit(1)
	} else {
		fmt.Println("\n✅ Installation completed successfully!")
		fmt.Println("You can now run the package manager again to select more packages.")
	}
}
