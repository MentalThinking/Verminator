# Verminator

The **PREMIER** method of exterminating vermin in Lusternia

## Dependencies

Requires the demonnic auto walker, available [HERE](https://github.com/demonnic/demonnicAutoWalker)

## Usage

* verminate
  * begin the weevil genocide!
* vstart
  * see verminate
* unverminate
  * Fine, give up and stop killing the enemy. Will return to where you started.
* vstop
  * see unverminate
* vpause
  * Grant the vermin masses temporary reprieve from your wrath
* vcont
  * Clemency is over, time once more to DIE!
* vshow
  * Show the stats window for Verminator
* vhide
  * Hide the stats window for Verminator
* vconfig
  * Used to set configuration options
  * valid options are
    * max_vermin_per_room
      * `vconfig max_vermin_per_room 6`
      * defaults to 3
      * may get adjusted by trigger later on
    * wait_time
      * `vconfig wait_time 15`
      * how long to wait since we last saw a vermin for the next one to pop
      * defaults to 10
    * fontSize
      * `vconfig fontSize 20`
      * how big to make the text in the stats window
    * font
      * `vconfig font Inconsolata`
      * what font to use for the stats windows
    * attack
      * `vconfig attack kill`
      * `vconfig attack point 12345 at`
      * `vconfig attack slaughter |t with lightning`
      * the command used to kill vermin. Use `|t` where the target should go. If not supplied, will be appended to the end, so `vconfig attack kill` would expand to `kill weevil`, `kill lizard`, etc.
