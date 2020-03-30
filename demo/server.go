package main

import (
  "fmt"
  "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
  go Fibo(3)
  fmt.Fprintf(w, "AAA")
}

func Fibo(n int) int {
    if n < 2 {
        return n
    }
    return Fibo(n-2) + Fibo(n-1)
}

func main() {
  http.HandleFunc("/", handler) // ハンドラを登録してウェブページを表示させる
  http.ListenAndServe(":8080", nil)
}