# Box Factory
## Principle
There are several isolates with inventories who trade, craft, etc.
They can:
- trade with eachother
- farm cows or sheep (adds one cow/sheep to inv)
- chop wood (add one log to inv)
- mine gold (add one gold ore to inv)
- craft 1 box for 12 planks
- craft 4 planks from 1 log
- craft 1 coin from 1 gold ore<br>
One isolate has no inventory and is instead the "server isolate" that stores the inventories.
## Protocol
Tuples, starting with a string, are sent from client to server to request a trade/farm/craft/etc.
Server sends back a tuple starting with a string.
### Client To Server
- ("index")
<br>Server sends index of player (used for trading)
- ("farm", "cow"/"sheep")
- ("chop")
- ("mine")
- ("craft", "coin"/"planks"/"box")
- ("trade", index, "cow"/"sheep"/"coin"/"planks"/"log"/"goldOre"/"box", amount)
<br> send \<amount>x\<$3> to \<index> isolate.
- ("getInv", "cow"/"sheep"/"coin"/"planks"/"log"/"goldOre"/"box")
### Server To Client
- ("invalid", "type", "must be record or string")
<br>Client did not send a record or a string (one-argument records are actually strings).
- ("invalid", "action")
<br>Starting string was not valid action, or record had wrong shape for that action.
- ("invalid", "index")
<br>`trade` did not send a valid person index
- ("invalid", "item")
<br>Invalid item / cannot farm/craft this item
- ("invalid", "amount")
<br>Traded more of an item then the client has, or a negative amount.
- ("invalid", "craft-attempt")
<br>Client does not have the resources to craft what they attempted to.
- ("success")
<br>Did what the client asked.
- (index)
<br>In response to client's "index"
- (amount)
<br>In response to client's "getInv"
## Behavior
- 0: farms cows and sheep for #1
- 1: trades 3 cows 1 sheep to #2 for 1 plank, makes boxes from 12 planks, and sells to #3 for 3 coins
- 2: chops wood, turns logs into 4 planks, trades 1 plank to #1 for 3 cows 1 sheep
- 3: mines gold, crafts coins from gold, and buys boxes from #1 for 3 coins
