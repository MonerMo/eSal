import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

@Injectable()
export class ShopOnlyGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();

    if (request.user?.accountType !== 'SHOP') {
      throw new ForbiddenException(
        'This endpoint is only available to shop accounts',
      );
    }

    if (!request.user?.storeId) {
      throw new ForbiddenException('Shop account is not linked to a store');
    }

    return true;
  }
}
