import { frontendURL } from '../../../../helper/URLHelper';

const SettingsContent = () => import('../Wrapper.vue');
const Index = () => import('./index.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/sla'),
      component: SettingsContent,
      props: {
        headerTitle: 'SLA',
        icon: 'key',
        showNewButton: true,
      },
      children: [
        {
          path: '',
          name: 'sla_wrapper',
          roles: ['administrator'],
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'sla_list',
          roles: ['administrator'],
          component: Index,
        },
      ],
    },
  ],
};
