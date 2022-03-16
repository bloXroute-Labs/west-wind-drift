# west-wind-drift

Examples of using bloXroute cloud services to work with stream of transactions and blocks from the Solana mainnet network and send transactions to the Solana mainnet network

## Endpoints
bloxroute runs Solana nodes in several locations around the world

The Available endpoints are:
* `virginia.solana.blxrbdn.com`
* `uk.solana.blxrbdn.com`
* `singapore.solana.blxrbdn.com`
* `solana.blxrbdn.com` routes to one of the above based on network latency

## Streams
This section details how to work with streams, aka feeds of data, including how to subscribe to a stream, handle stream notifications, and cancel a stream subscription

### Creating a Subscription
Subscriptions are created with the RPC call subscribe with the stream (feed) name and subscription options set as parameters. Each stream has a different subscription name and can accept different subscription options

`subscribe` returns a subscription ID that will be paired with all related notifications

**WebSocket connection Example wscat**

`wscat -c wss://solana.blxrbdn.com/ws --header "authorization:****" --execute '{"method":"subscribe", "params": ["newTxs", {"include": ["all"]}]}'`

### Available Streams
bloXroute supports the following feeds:
* newTxs - a stream of transactions
* newBlocks - a stream of blocks

#### newTxs
stream of transactions logging from the Solana mainnet network

**Options**

| Key     | Description | Values |
|---------|-------------|--------|
| include | Fields to include in the transaction stream. The subscription plan determines the list of available fields. | tx_hash, signature, *[Default: All]* | 
| filters | You can specify filters in SQL-Like format to only receive certain transactions | Users can customize the filters. | 

**Example - Golang**
```golang
package main

import (
	"fmt"
	"github.com/gorilla/websocket"
)

func main() {
	dialer := websocket.DefaultDialer
	wsSubscriber, _, err := dialer.Dial("wss://solana.blxrbdn.com", http.Header{"Authorization": []string{<YOUR-AUTHORIZATION-HEADER>})
	
	if err != nil {
		fmt.Println(err)
		return
	}

	subRequest := `{"id": 1, "method": "subscribe", "params": ["newTxs", {"include": []}]}`
	err = wsSubscriber.WriteMessage(websocket.TextMessage, []byte(subRequest))
	if err != nil {
		fmt.Println(err)
		return
	}

	for {
		_, nextNotification, err := wsSubscriber.ReadMessage()
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(string(nextNotification)) // or process it generally
	}
}
```

**Response (transaction logging Event)**
```json
{
  "jsonrpc":"2.0", 
  "method":"subscribe", 
  "params":{
    "subscription":"414f2873-a7b0-451c-aefa-4e9280f25ce7", 
    "result":{
      "Type":"newTxs", 
      "Tx":{
        "signature":"5X3fS5mK7ARihLNphrHo3xKaGRgksbFhXQKnmWZBwdELCAEpdGFZDThFpiakMjXUSxUXpCrKdXrcbUnVumWRHFNj", 
        "err":null, 
        "logs":[
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin invoke [1]",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin consumed 1590 of 200000 compute units",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin success",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin invoke [1]",
          "Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA invoke [2]",
          "Program log: Instruction: Transfer",
          "Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA consumed 2643 of 189068 compute units",
          "Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA success",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin consumed 14314 of 200000 compute units",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin success",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin invoke [1]",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin consumed 1590 of 200000 compute units",
          "Program 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin success"
        ]
      }
    }
  }
}
```

##### Filters
You can specify filters when subscribing to pendingTx and newTx streams to only receive certain transactions.‌ The filter string uses a SQL-like syntax for logical operations.
This filter dictionary is passed into the options argument of the subscribe() call:
`ws.subscribe("newTxs", {"filters": "...", ...})`

**Available Filters**
* all: subscribe to all transactions except for simple vote transactions
* allWithVotes: subscribe to all transactions including simple vote transactions
* mentions: subscribe to all transactions that mention the provided Pubkey (as base-58 encoded string)
* commitment: subscribe to transactions based on their commitment state
  * "finalized" - the node will query the most recent block confirmed by supermajority of the cluster as having reached maximum lockout, meaning the cluster has recognized this block as finalized
  * "confirmed" - the node will query the most recent block that has been voted on by supermajority of the cluster.
It incorporates votes from gossip and replay.
It does not count votes on descendants of a block, only direct votes on that block.
This confirmation level also upholds "optimistic confirmation" guarantees in release 1.3 and onwards.
  * "processed" - the node will query its most recent block. Note that the block may still be skipped by the cluster. 

Examples
```
# "mentions" Example
"({mentions} IN ['11111111111111111111111111111111']) AND ({commitment} == 'finalized')"

# wscat Subscribe Example
{"jsonrpc": "2.0", "id": 1, "method": "subscribe", "params": ["newTxs", {"include": ["all"], "filters": "({mentions} IN ['']) AND ({commitment} == 'finalized')"}]}
```

#### newBlocks
stream of blocks from the Solana mainnet network

**Options**

| Key     | Description                                                                                           | Values                                                                                            |
|---------|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| include | Fields to include in the block stream. | hash, transactions, slot, previousBlockhash, parentSlot, blockTime, blockHeight, *[Default: All]* | 

**Example - Golang**
```golang
package main

import (
	"fmt"
	"github.com/gorilla/websocket"
)

func main() {
	dialer := websocket.DefaultDialer
	wsSubscriber, _, err := dialer.Dial("wss://solana.blxrbdn.com", http.Header{"Authorization": []string{<YOUR-AUTHORIZATION-HEADER>})
	
	if err != nil {
		fmt.Println(err)
		return
	}

	subRequest := `{"id": 1, "method": "subscribe", "params": ["newBlocks", {"include": []}]}`
	err = wsSubscriber.WriteMessage(websocket.TextMessage, []byte(subRequest))
	if err != nil {
		fmt.Println(err)
		return
	}

	for {
		_, nextNotification, err := wsSubscriber.ReadMessage()
		if err != nil {
			fmt.Println(err)
		}
		fmt.Println(string(nextNotification)) // or process it generally
	}
}
```

**Response (Block Event)**
```json
{
  "jsonrpc": "2.0",
  "method": "subscribe",
  "params": {
    "subscription": "414f2873-a7b0-451c-aefa-4e9280f25ce7",
    "result": {
      "value": {
        "block": {
          "previousBlockhash": "DsKpw93CAo1FVGmXvrmFWWvNfbZ3ofJX2Ucyym7b6vmx",
          "blockhash": "2eX2U2NQd1Hjfv3vC5FBo2quDepGmDPAwNaaAoAXjJJP",
          "parentSlot": 124936318,
          "transactions": [
            ...
          ], 
          "blockTime": 1647280278,
          "blockHeight": 113022003
        }
      }
    }
  }
}
```

## Sending transactions
This endpoint allows you to send a single transaction to Solana

**REQUEST**

Method: blxr_tx

Parameters
| Parameter | Description |
|-----------|-------------|
| transaction| [Mandatory] Raw transactions bytes. |
