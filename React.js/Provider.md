# Global State

# Provider

## createContext

慣習として`src/providers`フォルダ配下にプロバイダーを作成していく。今回は例として`src/providers/UserProvider.jsx`

```jsx
// createContextを使用し、プロバイダーを作っていく
import React, { createContext } from 'react'

// UserContextという名称のブローバルなステートを定義
// 初期値としては空のオブジェクト
export const UserContext = createContext({})

// グローバルステートを返却するプロバイダーを作成
export const UserProvider = (props) => {
  const { children } = props
  const contextName = "haryu"
  return (
    <UserContext.Provider value={{ contextName }}>
      {children}
    </UserContext.Provider>
  )
}
```

この例では、contextName というグローバルステートを定義している

## グローバルステートを参照したいコンポーネントを囲む

全体で参照する際は、ルートコンポーネントを作成したプロバイダーで囲む

```jsx
App.js

import { UserProvider } from '.providers/UserProvider'

export default Add() {
  return (
    <UserProvier>
      <Router />
    </UserProvier>
  )
}
```

## グローバルステートを参照する

`useContext`を使用し、参照

```jsx
import { useContext } from 'react'
import { UserContext } from '../../providers/UserProvider'

// どのコンテキストを使用するか宣言
const context = useContext(UserContext)

console.log(context)
#=> haryu
```

## 応用 useStateを使用する例

```jsx
import React, { createContext, useState } from 'react'

export const UserContext = createContext({})

export const UserProvider = (props) => {
  const { children } = props
  const [userInfo, setUserInfo] = useState(null)
  return (
    // useInfoというステートと更新関数をグローバルとして扱える
    <UserContext.Provider value={{ userInfo, setUserInfo }}>
      {children}
    </UserContext.Provider>
  )
}
```

<br>

# useState and createContext with TypeScript

ステートと更新関数の型を定義する際に使うのは `Dispatch` と `SetStateAction`

```jsx
import { useState, Dispatch, SetStateAction } from 'react'
import { User } from '../types/api/user'

type LoginUserContextType = {
  loginUser: User | null
  setLoginUser: Dispatch<SetStateAction<User | null>>
}
//createContextしたLoginUserContextが保持する型を宣言
// as で初期値の型を明示
export const LoginUserContext = createContext<LoginUserContextType>({} as LoginUserContextType)

export const LoginUserProvider = (props: { children: ReactNode }) => {
  const [loginUser, setLoginUser] = useState<User | null>(null)

  return (
    <LoginUserContext.Provider value={{ loginUser, setLoginUser }}>
       {children}
    </LoginUserContext.Provider>
  )
}
```
