import { createRouter, createWebHistory } from 'vue-router'
import LayOut from '../views/layout/LayOut.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/home',
      component: () => import('../views/HomeView.vue')
    },
    {
      path: '/login',
      component: () => import('../views/LoginView.vue')
    },
    {
      path: '/register',
      component: () => import('../views/RegisterView.vue')
    },
    {
      path: '/about',
      component: () => import('../views/AboutView.vue')
    },
    {
      path: '/',
      redirect: '/notice',
      component: LayOut,
      children: [
        {
          path: '/self',
          component: () => import('../views/SelfView.vue')
        },
        {
          path: '/notice',
          component: () => import('../views/NoticeView.vue')
        },
        {
          path: '/reserve',
          component: () => import('../views/reserve/TabView.vue')
        },
        {
          path: '/user',
          component: () => import('../views/role/TabView.vue')
        },
        {
          path: '/device',
          component: () => import('../views/device/TabView.vue')
        },
        {
          path: '/system',
          component: () => import('../views/SystemView.vue')
        },
      ]
    },
    // {
    //   path: "*",
    //   component: () => import('../views/Error404.vue')
    // },
  ]
})

export default router
