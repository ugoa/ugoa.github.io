---
layout: post
title:  The problem statements of frontend and the what solution each and every JS framework provides
date:   2024-06-08 21:28:00 +0800
---


# A 100 ways to write a Counter application

## Plain JS
```html
<html>
  <head>
    <title>Counter App (Vanilla JS)</title>
    <script type="text/javascript">
      function updateCounter(operation) {
        const counterElement = document.getElementById('counter');
        let currentValue = parseInt(counterElement.innerHTML);
  
        if (operation === 'increment') {
          currentValue++;
        } else if (operation === 'decrement') {
          currentValue--;
        }
  
        counterElement.innerHTML = currentValue;
      }
  
      const incrementButton = document.getElementById('increment');
      incrementButton.addEventListener('click', () => updateCounter('increment'));
  
      const decrementButton = document.getElementById('decrement');
      decrementButton.addEventListener('click', () => updateCounter('decrement'));
    </script>
  </head>
  <body>
    <h1>Counter: <span id="counter">0</span></h1>
    <button id="increment">Increment</button>
    <button id="decrement">Decrement</button>
  </body>
</html>
```

## JQuery
```js
<html>
  <head>
    <title>Counter App (Vanilla JS)</title>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.3/jquery.min.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
        $('#increment').click(function() {
          $('#counter').text(parseInt($('#counter').text()) + 1);
        });

        $('#decrement').click(function() {
          $('#counter').text(parseInt($('#counter').text()) - 1);
        });
      });
    </script>
  </head>
  <body>
    <h1>Counter: <span id="counter">0</span></h1>
    <button id="increment">Increment</button>
    <button id="decrement">Decrement</button>
  </body>
</html>
```

## React
```jsx
import { React, useState } from 'react'
 
export default function App() {
  const [counter, setCounter] = useState(0);
 
  const increase = () => { setCounter(count => count + 1) };
  const decrease = () => { setCounter(count => count - 1) };
 
  const description = `You clicked ${counter} times`);
  return (
    <div>
      <span>{description}</span>
      <button onClick={increase}>+</button>
      <button onClick={decrease}>-</button>
    </div>
  );
}
```

## Vue

```vue
<script setup>
const counter = ref(0)
const description = computed(() => `You clicked ${count.value} times`);
</script>

<template>
  <span>{{ description }}</span>
  <button @click="counter++">+</button>
  <button @click="counter++">-</button>
</template>
```

## Svelte

```html
<script>
  let count = 0;
  $: description = `You clicked ${counter} times`);
  
  function handleClick() {
  	count += 1;
  }
</script>

<span>{description}</span>
<button on:click={handleClick}>
	clicks: {count}
</button>
```

## Solid

```jsx
function Counter() {
  const [counter, setCounter] = createSignal(0);
  const description = `You clicked ${counter()} times`);

  return (
    <div>
      <span> {description} </span>
      <button onClick={()=>setCounter(count=>count-1)}>+</button>
      <button onClick={()=>setCounter(count=>count+1)}>-</button>
    </div>
  );
}
```
