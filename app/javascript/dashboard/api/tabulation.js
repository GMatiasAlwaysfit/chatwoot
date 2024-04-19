import ApiClient from './ApiClient';

class TabulationApi extends ApiClient {
  constructor() {
    super('tabulations', { accountScoped: true });
  }
}

export default new TabulationApi();
