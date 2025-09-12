package main

import (
	"fmt"
	"os"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"linux-package-manager/internal/data"
)

type model struct {
	message    string
	dataLoader *data.DataLoader
	modules    []string
	profiles   []string
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
		// TODO: Add navigation logic here
		}
	}
	return m, nil
}

func (m model) View() string {
	var content strings.Builder
	
	content.WriteString(fmt.Sprintf("%s\n\n", m.message))
	
	// Show profiles for selection
	if len(m.profiles) > 0 {
		content.WriteString("Select a profile:\n")
		for _, profile := range m.profiles {
			content.WriteString(fmt.Sprintf("- %s\n", profile))
		}
		content.WriteString("\n")
	}
	
	content.WriteString("Controls:\n")
	content.WriteString("- Arrow keys: Navigate\n")
	content.WriteString("- Enter: Select/Confirm\n")
	content.WriteString("- Escape: Go back\n")
	content.WriteString("- Tab: Select packages\n")
	content.WriteString("- ?: Help\n")
	content.WriteString("- q or Ctrl+C: Quit\n")
	
	return content.String()
}

func main() {
	p := tea.NewProgram(initialModel())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}
}
