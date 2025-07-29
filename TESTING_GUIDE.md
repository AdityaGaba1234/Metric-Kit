# MetricKit Complete Testing Guide 🧪

## 📋 Full Onboarding Process (Start to Finish)

### Phase 1: Initial Setup (Day 1) 🚀

1. **Install & Launch**
   - Build and install the app on a **real iOS device** (iOS 13+)
   - Launch the app and see the initial screen
   - Verify status shows "MetricKit subscriber registered"

2. **First Day Activities**
   - Use "Simulate Work" button 5-10 times throughout the day
   - Keep the app open for at least 30 minutes
   - Use the app in background (home button, switch apps)
   - Close and reopen the app multiple times

### Phase 2: Generate Activity (Days 1-3) 📊

#### CPU Intensive Tasks
- Tap "Simulate Work" repeatedly (generates CPU metrics)
- Use app during different times of day
- Launch the app from cold start multiple times

#### Memory Usage
- The simulation creates large arrays (memory metrics)
- Keep app running for extended periods
- Switch between foreground/background frequently

#### Network Activity
- Use the app while connected to WiFi
- Switch to cellular data and use the app
- Download/upload data if your app has network features

#### Battery & Performance
- Use the app while device is charging
- Use the app on low battery
- Use during high device temperature

### Phase 3: Waiting Period (24-48 Hours) ⏰

**Important**: iOS delivers metrics approximately every 24 hours.

- **First 24 hours**: No metrics expected (normal)
- **After 24 hours**: First payload should arrive
- **After 48 hours**: More comprehensive data

### Phase 4: Analyzing Results (Day 2+) 📈

When metrics arrive, you'll see detailed logs including:

#### 🖥️ CPU Metrics
```
CPU METRICS:
• Cumulative CPU Time: 45.2s
• CPU Instructions: 2.1B instructions
```

#### 💾 Memory Metrics
```
MEMORY METRICS:
• Peak Memory Usage: 125.4 MB
• Average Suspended Memory: 89.2 MB
```

#### 🚀 Launch Metrics
```
LAUNCH METRICS:
• Time to First Draw Histogram:
  - 0.5s to 1.0s: 3 launches
  - 1.0s to 2.0s: 2 launches
```

#### ⚡ Responsiveness Metrics
```
RESPONSIVENESS METRICS:
• App Hang Time Histogram:
  - 100ms to 500ms: 1 hangs
  - 500ms to 1000ms: 0 hangs
```

## 🎯 Complete Testing Scenarios

### Scenario 1: Basic App Usage
**Goal**: Generate standard app metrics
- Open app daily for 1 week
- Use for 5-10 minutes each time
- Close properly (not force-quit)

**Expected Results**:
- CPU time metrics
- Memory usage patterns
- Launch time data
- Basic app runtime metrics

### Scenario 2: Performance Stress Testing
**Goal**: Generate performance-related metrics
- Use "Simulate Work" 20+ times
- Keep app running for hours
- Switch apps frequently during usage

**Expected Results**:
- Higher CPU usage metrics
- Memory pressure indicators
- Responsiveness issues (hangs)
- Performance degradation data

### Scenario 3: Network & Battery Testing
**Goal**: Generate network and power metrics
- Use app on both WiFi and cellular
- Use during different battery levels
- Use location services if available

**Expected Results**:
- Network transfer metrics
- Cellular vs WiFi usage
- Battery impact data
- Location usage metrics

### Scenario 4: App Lifecycle Testing
**Goal**: Generate launch and exit metrics
- Cold launch app 10+ times
- Background app frequently
- Force-quit occasionally (not recommended normally)

**Expected Results**:
- Launch time histograms
- App exit reason data
- Background vs foreground time
- App lifecycle metrics

## 📊 What Each Metric Tells You

### CPU Metrics
- **High CPU Time**: App is computationally intensive
- **CPU Instructions**: Complexity of operations
- **Use Case**: Optimize algorithms, reduce calculations

### Memory Metrics
- **Peak Memory**: Maximum memory used
- **Average Suspended**: Memory when backgrounded
- **Use Case**: Find memory leaks, optimize data structures

### Launch Metrics
- **Time to First Draw**: App startup speed
- **Launch Histogram**: Distribution of launch times
- **Use Case**: Optimize app startup, reduce launch time

### Responsiveness Metrics
- **App Hang Time**: When UI freezes
- **Hang Histogram**: Frequency and duration of hangs
- **Use Case**: Fix UI blocking operations, improve smoothness

### Network Metrics
- **WiFi vs Cellular**: Data usage patterns
- **Upload vs Download**: Data transfer direction
- **Use Case**: Optimize network usage, reduce data costs

### Battery Metrics
- **GPU Time**: Graphics processing usage
- **Location Time**: GPS usage
- **Use Case**: Reduce battery drain, optimize power usage

## 🔍 Troubleshooting

### "No Metrics Yet" - Normal Scenarios
- ✅ First 24 hours of app installation
- ✅ App hasn't been used enough (need regular usage)
- ✅ iOS hasn't reached its delivery schedule yet

### "No Metrics Yet" - Problem Scenarios
- ❌ Using iOS Simulator (MetricKit only works on real devices)
- ❌ iOS version below 13.0
- ❌ App was force-quit immediately after launch
- ❌ Device storage is full

### Getting More Detailed Metrics
1. **Use app regularly** for at least 1 week
2. **Perform varied activities** (not just one task)
3. **Use different network conditions**
4. **Launch app at different times of day**
5. **Keep app installed** (don't reinstall frequently)

## 📅 Expected Timeline

### Day 1
- ✅ Install app
- ✅ Register for MetricKit
- ✅ Generate initial activity
- ❌ No metrics yet (normal)

### Day 2
- ✅ First metrics payload arrives
- ✅ Basic CPU and memory data
- ✅ Launch metrics if multiple launches
- ❌ Limited histogram data

### Day 3-7
- ✅ Comprehensive metrics
- ✅ Detailed histograms
- ✅ Network usage patterns
- ✅ Performance trend data

### Week 2+
- ✅ Rich historical data
- ✅ Performance trends
- ✅ Optimization opportunities
- ✅ Full MetricKit experience

## 💡 Pro Tips

1. **Export Logs**: Use the "Export Logs" button to save data
2. **Pattern Recognition**: Look for trends over multiple days
3. **Correlation**: Match metrics with app features you used
4. **Optimization**: Use data to improve app performance
5. **Monitoring**: Set up regular testing schedule

## 🚨 Important Notes

- **Real Device Only**: MetricKit doesn't work in simulator
- **24-Hour Cycle**: Metrics arrive once per day maximum
- **Privacy First**: All data is aggregated and anonymous
- **System Dependent**: iOS controls when metrics are delivered
- **Cumulative Data**: Metrics show totals since last delivery

---

**Remember**: MetricKit is designed for long-term monitoring, not real-time debugging. Be patient and consistent with your testing! 📊
