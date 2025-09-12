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

// Styling
var (
	// Colors
	primaryColor   = lipgloss.Color("#00D4AA") // Teal
	secondaryColor = lipgloss.Color("#7C3AED") // Purple
	accentColor    = lipgloss.Color("#F59E0B") // Amber
	textColor      = lipgloss.Color("#F8FAFC") // Light gray
	mutedColor     = lipgloss.Color("#64748B") // Gray
	
	// Styles
	titleStyle = lipgloss.NewStyle().
			Foreground(primaryColor).
			Bold(true).
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
			Margin(1, 0)
	
	boxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(primaryColor).
			Padding(1, 2).
			Margin(1, 0)
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
	return nil
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
			}
		case "enter":
			if m.currentView == "profile_selection" {
				// Move to module selection for selected profile
				m.currentView = "module_selection"
				m.selectedModule = 0
			} else if m.currentView == "module_selection" {
				// Move to submodule selection for selected module
				m.currentView = "submodule_selection"
				m.selectedSubmodule = 0
			}
		case "esc":
			if m.currentView == "module_selection" {
				// Go back to profile selection
				m.currentView = "profile_selection"
			}
		}
	}
	return m, nil
}

func (m model) View() string {
	var content strings.Builder
	
	// Title
	content.WriteString(titleStyle.Render("🚀 Linux Package Manager TUI"))
	content.WriteString("\n\n")
	
	if m.currentView == "profile_selection" {
		// Show profiles for selection
		if len(m.profiles) > 0 {
			content.WriteString(headerStyle.Render("Select a profile:"))
			content.WriteString("\n")
			
			for i, profile := range m.profiles {
				if i == m.selectedProfile {
					content.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s", profile)))
				} else {
					content.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s", profile)))
				}
				content.WriteString("\n")
			}
			content.WriteString("\n")
		}
	} else if m.currentView == "module_selection" {
		// Show modules for selected profile
		selectedProfileName := m.profiles[m.selectedProfile]
		content.WriteString(headerStyle.Render(fmt.Sprintf("Profile: %s", selectedProfileName)))
		content.WriteString("\n")
		
		// Get available modules for this profile
		profile, exists := m.dataLoader.GetProfile(selectedProfileName)
		if exists {
			if selectedProfileName == "newbie" {
				// Newbie profile shows use cases instead of modules
				content.WriteString(headerStyle.Render("Select a use case:"))
				content.WriteString("\n")
				useCaseIndex := 0
				for useCase := range profile.UseCases {
					if useCaseIndex == m.selectedModule {
						content.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s", useCase)))
					} else {
						content.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s", useCase)))
					}
					content.WriteString("\n")
					useCaseIndex++
				}
			} else {
				// Other profiles show modules
				content.WriteString(headerStyle.Render("Available modules:"))
				content.WriteString("\n")
				for i, moduleName := range profile.Modules {
					if i == m.selectedModule {
						content.WriteString(selectedStyle.Render(fmt.Sprintf("▶ %s", moduleName)))
					} else {
						content.WriteString(unselectedStyle.Render(fmt.Sprintf("  %s", moduleName)))
					}
					content.WriteString("\n")
				}
			}
		}
		content.WriteString("\n")
	}
	
	// Controls
	controls := []string{
		"↑↓ Arrow keys: Navigate",
		"⏎ Enter: Select/Confirm",
		"⎋ Escape: Go back",
		"⇥ Tab: Select packages",
		"? Help: Show help",
		"q or Ctrl+C: Quit",
	}
	
	content.WriteString(controlsStyle.Render(strings.Join(controls, " • ")))
	
	return content.String()
}

func main() {
	p := tea.NewProgram(initialModel())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}
}
