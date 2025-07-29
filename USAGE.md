# MetricKit Demo - Quick Start Guide 🚀

## What You'll See

### 1. App Interface
- **Title**: "MetricKit Demo App" at the top
- **Status**: Shows current MetricKit state
- **Three Buttons**:
  - 🔴 **Clear Logs**: Removes all displayed logs
  - 🟢 **Simulate Work**: Generates CPU/memory activity
  - 🔵 **Export Logs**: Share logs via text/email
- **Statistics**: Shows metrics count and app uptime
- **Log Display**: Terminal-style view showing detailed metrics

### 2. Understanding the Logs

When metrics arrive, you'll see detailed information like:

```
📦 === METRIC PAYLOAD #1 ===
🕐 Timestamp: 1/11/25, 2:30:45 PM
📋 Payload Info:
   • Time Range: Duration: 24.0h

🖥️  CPU METRICS:
   • Cumulative CPU Time: 45.2s
   • CPU Instructions: 2.1B instructions

💾 MEMORY METRICS:
   • Peak Memory Usage: 125.4 MB
   • Average Suspended Memory: 89.2 MB

🌐 NETWORK METRICS:
   • Cumulative WiFi Download: 15.6 MB
   • Cumulative Cellular Upload: 2.1 MB
```

### 3. How to Use

#### First Time Setup
1. **Install the app** on a real device (not simulator)
2. **Launch the app** - you'll see "Waiting for metrics..."
3. **Use "Simulate Work"** to generate some activity
4. **Wait** - real metrics come from iOS after ~24 hours of usage

#### Daily Usage
1. **Check regularly** for new metric payloads
2. **Use buttons** to interact with the data
3. **Export logs** to save or analyze data externally

### 4. Important Notes

- **Real Device Only**: MetricKit doesn't work in the iOS Simulator
- **24-Hour Cycle**: iOS delivers metrics approximately once per day
- **Cumulative Data**: Metrics show totals since last delivery
- **Privacy First**: All data is aggregated and anonymized

### 5. What Each Metric Means

- **CPU Time**: How much processor time your app used
- **Memory Usage**: Peak and average memory consumption
- **Network Data**: WiFi vs cellular data usage
- **Launch Times**: How long your app takes to start
- **Hangs**: Times when your app was unresponsive

### 6. Troubleshooting

**"No metrics yet"** → Normal for new apps, wait 24+ hours
**"App crashes"** → Check iOS version (requires iOS 13+)
**"No network data"** → Use the app with internet activity

---

**Pro Tip**: Keep the app installed and use it regularly for a few days to see the most comprehensive metrics data! 📊
