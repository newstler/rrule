# RRule

## Description

RRule is a minimalist package for expanding RRULEs, with a goal of being fully compliant with [iCalendar spec](https://tools.ietf.org/html/rfc2445).

## Examples

To use this package, add this to your code:

```swift
import RRule
```

Create a rrule with a RRULE string:

```swift
let rrule = RRule.parse('FREQ=DAILY;COUNT=3')
```

### Generating recurrence instances

Either generate all instances of a recurrence, or generate instances in a range:

```swift
rrule.all
// [2024-06-23 16:45:32 -0700, 2024-06-24 16:45:32 -0700, 2024-06-25 16:45:32 -0700]

let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 23))
let endDate = Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 24))
rrule.between(startDate: startDate, endDate: endDate)
// [2024-06-23 16:45:32 -0700]
```

You can generate all instances starting from a specified date with the `#from` method:

```swift
let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1))
let rrule = RRule.parse('FREQ=DAILY;COUNT=3', startDate)
rrule.all
// [2024-01-01 16:45:32 -0700, 2024-01-02 16:45:32 -0700, 2024-01-03 16:45:32 -0700]

let date = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 2))
rrule.from(startDate: date)
// [2024-01-02 16:45:32 -0700, 2024-01-03 16:45:32 -0700]
```

You can limit the number of instances that are returned with the `limit` option:

```swift
let rrule = RRule.parse('FREQ=DAILY;COUNT=3')
rrule.all(limit: 2)
=> [2016-06-23 16:45:32 -0700, 2016-06-24 16:45:32 -0700]
```

By default the DTSTART of the recurrence is the current time, but this can be overriden with the `dtstart` option:

```swift
let date = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 2))
let rrule = RRule.parse('FREQ=DAILY;COUNT=3', dtstart: date)
rrule.all
=> [2024-07-01 00:00:00 -0700, 2024-07-02 00:00:00 -0700, 2024-07-03 00:00:00 -0700]
```

Unless your rrule should be evaluated in UTC time, you should also pass an explicit timezone in the `tzid` option to ensure that daylight saving time boundaries are respected, etc.:

```swift
let date = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 1))
let rrule = RRule.parse('FREQ=DAILY;COUNT=3', dtstart: date, tzid: 'America/Los_Angeles')
```

### Exceptions (EXDATEs)

To define exception dates, pass the `exdate` option:

```swift
let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 1))
let exDate = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 2))
let rrule = RRule.parse('FREQ=DAILY;COUNT=3', dtstart: startDate, exdate: [exDate])
rrule.all
=> [2024-07-01 00:00:00 -0700, 2024-07-03 00:00:00 -0700]
```

## Contributing

Contributions are welcome! Report bugs and submit pull requests on [GitHub](https://github.com/newstler/rrule).

## License

This package is open source under the [MIT License](https://opensource.org/licenses/MIT).

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
