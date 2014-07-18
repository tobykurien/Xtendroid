package org.xtendroid.annotations

import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import java.lang.annotation.Target
import java.lang.annotation.ElementType

@Active(typeof(LogTagProcessor))
@Target(ElementType.TYPE)
annotation AndroidLoader {
	boolean keepResult = true
}

class AndroidLoaderProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
//		clazz.addMethod("")
	}
}

/*
public class ChangePasswordLoader extends AsyncTaskLoader<MBDocument>
{
  public ChangePasswordLoader(Context context, final String accountId, final char[] oldPassword, final char[] newPassword)
  {
    super(context);
    this.accountId = accountId;
    this.oldPassword = oldPassword;
    this.newPassword = newPassword;
  }

  @Override
  protected void onStartLoading()
  {
  * normally:
  * 
  * if (responseDoc == null)
  * {
  *     forceLoad();
  * }
  * 
  * 
    this.responseDoc = null;
    forceLoad(); // do not use the cache, run #loadInBackground
  }

  @Override
  protected void onStopLoading()
  {
    cancelLoad();
  }

  @Override
  protected void onReset()
  {
    cancelLoad();
  }

  @Override
  public void onCanceled(MBDocument data)
  {
    super.onCanceled(data);
    responseDoc = null;
  }

  // should this be overloaded?
  @Override
  protected void onAbandon()
  {
    super.onAbandon();
    responseDoc = null;
  }

  @Override
  public MBDocument loadInBackground()
  {
    RestServiceDataHandler restServiceDataHandler = new RestServiceDataHandler();
    MBDocument mbDocument = restServiceDataHandler.doLoadDocument("DOCUMENT-result-account", createRequestDocument());

    return mbDocument;
  }

  @Override
  public void deliverResult(MBDocument data)
  {
    super.deliverResult(data);
    this.responseDoc = data; // store result
  }

}
 * */