# Keyboard Shortcuts

modelman provides comprehensive keyboard shortcuts to make your workflow faster and more efficient. Press `?` or `Shift+?` anytime to view all available shortcuts.

**Note**: All shortcuts use simple keys without modifiers (except Cmd+Enter for execute) to avoid conflicts with browser shortcuts!

## 🚀 Quick Reference

### Servers
| Shortcut | Action |
|----------|--------|
| `↑` | Previous server |
| `↓` | Next server |
| `a` | Add new server |

### Tools
| Shortcut | Action |
|----------|--------|
| `/` | Focus on tool search |
| `k` | Previous tool (Vim-style) |
| `j` | Next tool (Vim-style) |
| `⌘/Ctrl + Enter` | Execute current tool |
| `m` | Toggle Form/JSON input mode |

### General
| Shortcut | Action |
|----------|--------|
| `Shift + ?` | Show keyboard shortcuts modal |
| `Escape` | Close modal or clear search |

## 💡 Tips

- **Vim-style Everything**: Inspired by Vim - `/` for search, `j/k` for navigation
- **Auto-scroll**: When navigating with `j/k` or arrow keys, the sidebar automatically scrolls to keep the selected item visible
- **No Modifier Keys**: Simple single-key shortcuts (except execute which uses Cmd+Enter - a common pattern)
- **Arrow Keys for Servers**: Use `↑/↓` to navigate servers
- **Letters for Tools**: Use `j/k` to navigate tools (Vim-style down/up)
- **Quick Actions**: `a` to add, `Cmd+Enter` to execute, `m` to toggle mode
- **Modal Management**: Press `Escape` to close any open modal or clear the search

## 🎯 Smart Features

### Instant Auto-Scroll
- When navigating with keyboard shortcuts, the sidebar **instantly scrolls** to keep the selected item visible
- Constant-time scroll - takes the same time whether navigating one item or across the entire list
- No animation delay means you can rapidly navigate through long lists
- Works for both servers (`↑/↓`) and tools (`j/k`)

### Context-Aware
- Shortcuts are **context-aware** and won't interfere when you're typing in input fields
- **Arrow keys (`↑/↓`)** navigate servers
- **Vim keys (`j/k`)** navigate tools - clear separation, no confusion!
- The `Escape` key intelligently closes modals or clears search based on context
- Tool execution shortcuts only work when a tool is selected and ready to execute

## 🦉 Visual Hints

Keyboard shortcuts are visible throughout the UI:
- **Add Server button** shows `A` directly on the button
- **Search box** displays `/` shortcut hint
- **Header keyboard icon** opens the full shortcuts modal
- Hover over buttons to see additional shortcuts in tooltips

## 🚫 No Browser Conflicts

All shortcuts are carefully chosen to avoid browser conflicts:
- ❌ No `Ctrl/Cmd+N` (opens new window)
- ❌ No `Ctrl/Cmd+T` (opens new tab)
- ❌ No `Ctrl/Cmd+W` (closes tab)
- ❌ No `Ctrl/Cmd+R` (reloads page)
- ✅ `Cmd+Enter` is safe - commonly used for "submit" actions!

## Accessibility

All keyboard shortcuts are designed with accessibility in mind:
- **Clear focus indicators** show where you are
- **Skip navigation** with keyboard-only interaction
- **Screen reader friendly** with proper ARIA labels
- **Auto-scroll** ensures selected items are always visible

---

Press `Shift + ?` anytime to see the interactive shortcuts modal! 🚀

