global:
  smtp_smarthost: 'smtp4dev:25'
  smtp_from: 'alertmanager@example.org'
  smtp_require_tls: false

route:
  group_by: ["group"]
  receiver: team-mails
  routes:
    - receiver: team-mails
      # time to wait for grouping alarms when sending the first notification
      group_wait: 30s
      # time to wait for grouping new alarms when sending further notifications for the same group
      group_interval: 1m
      # should be a multiple of group_interval
      repeat_interval: 2h
      mute_time_intervals: ["weekday-off-evenings", "weekday-off-mornings", "weekends"]
      matchers:
        - severity =~ "warning|critical"
    - receiver: team-slack-and-emails
      # time to wait for grouping alarms when sending the first notification
      group_wait: 30s
      # time to wait for grouping new alarms when sending further notifications for the same group
      group_interval: 1m
      # should be a multiple of group_interval
      repeat_interval: 2m
      matchers:    
        - severity =~ "critical"

time_intervals:
  - name: "working-hours"
    time_intervals:
    - times:
      - start_time: "09:00"
        end_time: "18:00"
      location: "Europe/Rome"
      weekdays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  - name: "weekday-off-evenings"
    time_intervals:
    - times:
      - start_time: "18:00"
        end_time: "23:59"
      location: "Europe/Rome"
      weekdays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  - name: "weekday-off-mornings"
    time_intervals:
    - times:
      - start_time: "00:00"
        end_time: "08:59"
      location: "Europe/Rome"
      weekdays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  - name: "weekends"
    time_intervals:
      - times:
        - start_time: "00:00"
          end_time: "23:59"
        location: "Europe/Rome"
        weekdays: ['Saturday', 'Sunday']

receivers:
  - name: "team-mails"
    email_configs: 
      - to: "test-receiver@example.com"
        send_resolved: true
  - name: "team-slack-and-emails"
    email_configs: 
      - to: "test-receiver@example.com"
        send_resolved: true
    slack_configs:
      - send_resolved: true
        channel: "#rabbitmq-management"
        api_url: "env.SLACK_API_URL"
        title: |-
          [{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }} for {{ .CommonLabels.job }}
          {{- if gt (len .CommonLabels) (len .GroupLabels) -}}
            {{" "}}(
            {{- with .CommonLabels.Remove .GroupLabels.Names }}
              {{- range $index, $label := .SortedPairs -}}
                {{ if $index }}, {{ end }}
                {{- $label.Name }}="{{ $label.Value -}}"
              {{- end }}
            {{- end -}}
            )
          {{- end }}
        text: >-
          {{ range .Alerts -}}
          *Alert:* {{ .Annotations.title }}{{ if .Labels.severity }} - `{{ .Labels.severity }}`{{ end }}

          *Description:* {{ .Annotations.description }}

          *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}
