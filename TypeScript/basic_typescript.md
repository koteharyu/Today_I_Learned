# 関数の型定義

1. パラメーター: 関数宣言時に渡される値（仮パラメータ）
2. 引数: 関数を呼び出す際に渡す値（実パラメーター）
3. 戻り値: 関数が返す値

```ts
const logMessage = (message: string): void => {
  console.log(message)
}

logMessage("hello Haryu")
```

1. message: string
2. “hello Haryu”
3. void...returnしない関数の型

# 関数の記述方法4選

```ts
// アロー関数
export const logMsg1 = (message: string): void => {
  console.log("hello 1")
}

// 名前付き関数
export function logMsg2(message: string): void {
  console.log("hello 2")
}

// 関数式
export const logMsg3 =  function (message: string): void {
  console.log("hello 3")
}

// アロー関数の省略形 returnしなければ{}を省略できる
export const logMsg4 = (message: string): void => console.log("hello 4")
```

# シグネチャ

1. 省略形の記法
2. 完全な記法

Reactで関数をpropsで渡すときとかによく使われるみたい

```ts
type LogMessage = (message: string) => :void

export const logMsg: LogMessage = (message) => {
  console.log("use 省略記法のシグネチャ")
}
```

```ts
type FullLogMessage = {
  (message: string): void
}

export const logMsg2: FullLogMessage = (message) => {
  console.log("use 完全記法のシグネチャ")
}
```

# Object型に意味はない

```ts
const ishida: object = {
  name: "haryu",
  age: 24
}

a.name
```

aというオブジェクトにnameというパラメーターはないと怒られる

そのため`オブジェクトリテラル記法`を使用して型定義する

注意...`変数の区切りに,を使用しない`

```ts
const ishida: {
  name: string
  age: number
} = {
  name: "haryu",
  age: 24
}

console.log(isida)
#=> {name: "haryu", age: 24}
```

# 配列に秩序を持たせる型定義

string型の配列であることを定義

```ts
const colors: string[] = ["red", "blue"]
```

2種の定義方法

```ts
const odd: number[] = [1,3,5]
const even: Array<number> = [2,4,6]
```

タプル…厳格な配列。要素数を指定できる

```ts
const tuple: [number, string, number] = [1, "OK", 100]

tuple = [2, "haryu", 100] // OK
tuple = [2, "haryu", "haryu"] // NG
tuple = [2, "haryu", 100, "haryu"] // NG
```

`ミュータブル`...書き換え可能

`イミュータブル`...書き換え不可能`ReadOnly`

```ts
const gitCommands: readonly string[] = ["git add", "git commit", "git push"]
gitCommands.push("git pull") // NG
gitCommands[0] = "git rebase" // NG
```

その他の`イミュータブル`な書き方

```ts
const gitCommands: ReadonlyArray<string> = ["git add", "git commit", "git push"]
const gitCommands: Readonly<string[]> = ["git add", "git commit", "git push"]
```

# extends

`extends`...大元のクラスを継承する際に使う

```ts
class Piece {}

class Osho extends Piece {}
```

# type Alias

交差型

```ts
type カレー = {
  カロリー: number,
  辛さ: number
}

type 米 ={
  カロリー: number,
  硬さ: number
}

type カレーライス: カレー & 米

const CurryRice: カレーライス = {
  カロリー: 1000,
  辛さ: 8,
  硬さ: 9
}
```

# 非同期

非同期処理は便利だが、いつ始まっていつ終わったかがわかりずらい
そのため `promise`, `async/await` を使って非同期処理を同期的に扱うようにする
