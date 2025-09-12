package main

import (
	"fmt"
	"os"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"linux-package-manager/internal/data"
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
	message    string
	dataLoader *data.DataLoader
	modules    []string
	profiles   []string
	
	// Navigation state
	currentView string // "profile_selection", "module_selection", "submodule_selection"
	selectedProfile int
	selectedModule int
	selectedSubmodule int
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

	return model{
		message:    "Linux Package Manager TUI",
		dataLoader: loader,
		modules:    loader.ListModules(),
		profiles:   loader.ListProfiles(),
		currentView: "profile_selection",
		selectedProfile: 0,
		selectedModule: 0,
		selectedSubmodule: 0,
	}
}

func (m model) Init() tea.Cmd {
	return tea.ClearScreen
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
				m.selectedModule = max(0, m.selectedModule-1)
			} else if m.currentView == "submodule_selection" {
				m.selectedSubmodule = max(0, m.selectedSubmodule-1)
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
						// Other profiles use modules
						m.selectedModule = min(len(profile.Modules)-1, m.selectedModule+1)
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
			}
		case "enter":
			if m.currentView == "profile_selection" {
				// Move to module selection for selected profile
				m.currentView = "module_selection"
				m.selectedModule = 0
				return m, tea.ClearScreen
			} else if m.currentView == "module_selection" {
				// Move to submodule selection for selected module
				m.currentView = "submodule_selection"
				m.selectedSubmodule = 0
				return m, tea.ClearScreen
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
	}
	
	// Apply window border to content
	content.WriteString(windowStyle.Render(windowContent.String()))
	content.WriteString("\n")
	
	// Simplified controls at the bottom (outside the window)
	controls := "↑↓ Navigate • ⏎ Select • ⎋ Back • q Quit"
	content.WriteString(controlsStyle.Render(controls))
	
	return content.String()
}

func main() {
	p := tea.NewProgram(initialModel())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}
}

