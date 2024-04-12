import { frontendURL } from '../../../../helper/URLHelper';

const SettingsContent = () => import('../Wrapper.vue');
const Index = () => import('./Index.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/tabulation'),
      component: SettingsContent,
      props: {
        headerTitle: 'Tabulação',
        icon: 'key',
        showNewButton: true,
      },
      children: [
        {
          path: '',
          name: 'tabulation_wrapper',
          roles: ['administrator'],
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'tabulation_list',
          roles: ['administrator'],
          component: Index,
        },
      ],
    },
  ],
};
