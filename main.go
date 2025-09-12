package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
)

type model struct {
	message    string
	keyPressed string
}

func initialModel() model {
	return model{
		message:    "Linux Package Manager TUI - Keybind Test",
		keyPressed: "No key pressed yet",
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
			m.keyPressed = "↑ Up arrow pressed"
		case "down":
			m.keyPressed = "↓ Down arrow pressed"
		case "left":
			m.keyPressed = "← Left arrow pressed"
		case "right":
			m.keyPressed = "→ Right arrow pressed"
		case "enter":
			m.keyPressed = "⏎ Enter pressed"
		case "esc":
			m.keyPressed = "⎋ Escape pressed"
		case "tab":
			m.keyPressed = "⇥ Tab pressed"
		case "?":
			m.keyPressed = "? Help key pressed"
		default:
			m.keyPressed = fmt.Sprintf("Key pressed: %s", msg.String())
		}
	}
	return m, nil
}

func (m model) View() string {
	return fmt.Sprintf(`%s

%s

Keybind Test:
- Arrow keys: Navigate
- Enter: Select/Confirm
- Escape: Go back
- Tab: Select packages
- ?: Help
- q or Ctrl+C: Quit

Press any key to test...`, m.message, m.keyPressed)
}

func main() {
	p := tea.NewProgram(initialModel())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}
}
