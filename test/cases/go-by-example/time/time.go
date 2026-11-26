// Go offers extensive support for times and durations;
// here are some examples.

package main

import (
	"fmt"
	"time"
)

func main() {
	p := fmt.Println

	// We'll start by getting the current time.
	now := time.Now()
	p(now)

	// You can build a `time` struct by providing the
	// year, month, day, etc. Times are always associated
	// with a `Location`, i.e. time zone.
	that := time.Date(
		2009, 11, 17, 20, 34, 58, 651387237, time.UTC)
	p(that)

	// You can extract the various components of the time
	// value as expected.
	p(that.Year())
	p(that.Month())
	p(that.Day())
	p(that.Hour())
	p(that.Minute())
	p(that.Second())
	p(that.Nanosecond())
	p(that.Location())

	// The Monday-Sunday `Weekday` is also available.
	p(that.Weekday())

	// These methods compare two times, testing if the
	// first occurs before, after, or at the same time
	// as the second, respectively.
	p(that.Before(now))
	p(that.After(now))
	p(that.Equal(now))

	// The `Sub` methods returns a `Duration` representing
	// the interval between two times.
	diff := now.Sub(that)
	p(diff)

	// We can compute the length of the duration in
	// various units.
	p(diff.Hours())
	p(diff.Minutes())
	p(diff.Seconds())
	p(diff.Nanoseconds())

	// You can use `Add` to advance a time by a given
	// duration, or with a `-` to move backwards by a
	// duration.
	p(that.Add(diff))
	p(that.Add(-diff))
}
