tell application "iTerm"
  activate

  set myterm to (make new terminal)

  set the name of the first window to "<%= @project_name %>"

  tell myterm
    set number of columns to 100
    set number of rows to 50

    -- set up tabs and panes
    <% @tabs.each_with_index do |tab, i| %>
      <% session = "session#{i}" %>

      -- tab "<%= tab.name %>"
      set <%= session %> to (launch session "<%= tab.name %>")

      tell <%= session %>
        <% if tab.command %>
          write text "cd <%= @project_root %> && <%= tab.command %>"
        <% elsif tab.panes %>
          -- tmux select-layout -t <%= window(i+1) %> <%=s tab.layout %>
          write text "cd <%= @project_root %> && <%= tab.panes.shift %>"
          <% tab.panes.each do |pane| %>
            tell application "System Events" to keystroke "d" using command down
            write text "cd <%= @project_root %> && <%= pane %>"
          <% end %>
        <% end %>
      end tell
    <% end %>

    <% if @pre %>
      set pre_session to (launch session "pre")
      tell pre_session
        -- run the pre stuff
        write text "<%= @pre.kind_of?(Array) ? @pre.join(" && ") : @pre %>"
      end tell
      terminate pre_session
    <% end %>

  end tell

  -- select window 1
  select the first session of myterm
end tell
